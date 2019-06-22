require 'nokogiri'
require 'httparty'
require 'uri'
require 'cgi'

class Driver
  include HTTParty
  base_uri 'drivetothetarget.web.ctfcompetition.com'

  MAX_VELOCITY = 0.0008 / 7.3 * 1.4 # degrees / seconds

  attr_accessor :lat, :lon, :token
  attr_accessor :dir, :status, :flag
  attr_reader   :freq, :move_delta

  #attr_accessor :last_move_time

  def initialize(freq, last_url)
    self.lat = nil
    self.lon = nil
    self.token = nil

    self.dir = :sw
    self.status = :farther
    self.flag = nil

    @freq = freq
    @move_delta = freq * MAX_VELOCITY * 0.7071 # per leg of triangle

    if last_url
      init_params_from_url(last_url)
    else
      # Get our initial position
      #self.last_move_time = Time.now.to_f
      move
    end

  end

  def drive
    # Are we there yet?
    while status != :there
      pick_destination
      move

      case status
      when :farther
        # We need to back track?
        turn_around
        # or maybe switch axes?
      when :closer
        # Keep going!
      end

      # Asleep at the wheel...
      sleep freq
    end

    print_flag
  end

  private

  def move
    print "Heading towards #{lat.round(4)}, #{lon.round(4)}... " if lat && lon

    resp = self.class.get('/', drive_options)

    if resp.code == 200
      # Persist the state
      `echo "#{self.class.base_uri}/?lat=#{lat}&lon=#{lon}&token=#{token}" >> move_reqs`
      parse_response(resp)
    else
      raise RuntimeError.new("Something went wrong! Response:\n#{resp}")
    end
  end

  def pick_destination
    #print "Updating destination from (#{lat}, #{lon}) to "

    # Depending on our direction, update the location as necessary
    case dir
    when :sw
      self.lat -= move_delta
      self.lon -= move_delta
    when :ne
      self.lat += move_delta
      self.lon += move_delta
    end

    #puts "(#{lat}, #{lon})..."
  end

  def turn_around
    puts "Turning around..."

    case dir
    when :sw
      self.dir = :ne
    when :ne
      self.dir = :sw
    end
  end

  def print_flag
    puts "We're there!\nFlag: #{flag}"
  end

  def parse_response(resp)
    parsed = Nokogiri::HTML(resp)

    # Get the new input values
    lat_input = parsed.css('input[name="lat"]')[0]
    lon_input = parsed.css('input[name="lon"]')[0]
    tok_input = parsed.css('input[name="token"]')[0]

    self.lat = input_value(lat_input).to_f
    self.lon = input_value(lon_input).to_f
    self.token = input_value(tok_input)

    # Update our status
    status_tag = parsed.css('p')[1]
    self.status = parse_status(status_tag)
  end

  def input_value(inp)
    inp.attributes["value"].value
  end

  def parse_status(tag)
    return :farther unless tag.children.length > 0

    case tag.children[0].text
    when /should move/
      # We aren't going anywhere...
      raise RuntimeError.new("Something went wrong! We didn't move...") if token
    when /getting away/
      puts "Getting further away."
      ret = :farther
    when /getting closer/
      puts "Getting closer."
      ret = :closer
    else
      puts tag.children[0].text
      return :closer # don't change anything
    end

    #move_time = Time.now.to_f
    #puts "Seconds between valid moves: #{move_time - self.last_move_time}"
    #self.last_move_time = move_time

    ret
  end

  def init_params_from_url(url)
    query_hash = CGI.parse(URI.parse(url).query)
    [:lat, :lon, :token].each do |param|
      if not query_hash.include? param.to_s
        raise RuntimeError.new("Bad URL to load from: #{url}")
      end
    end

    self.lat = query_hash["lat"][0].to_f
    self.lon = query_hash["lon"][0].to_f
    self.token = query_hash["token"][0]
  end

  def drive_options
    options = { query: {} }
    options[:query][:lat] = lat.round(4) if lat
    options[:query][:lon] = lon.round(4) if lon
    options[:query][:token] = token if token

    options
  end
end

def main
  freq = ARGV[0]&.to_f || 1.0
  file = ARGV[1] if ARGV.length > 1

  if file
    last_url = `tail -n 1 #{file}`
  end

  driver = Driver.new(freq, last_url)
  driver.drive
end

main
