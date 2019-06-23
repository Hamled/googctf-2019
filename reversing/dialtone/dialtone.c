#include <stdio.h>
#include <complex.h>
#include <pulse/simple.h>
#include <pulse/error.h>

// obj.ss.3811 @ 0x00001768
static const pa_sample_spec ss = {
  .format = PA_SAMPLE_FLOAT32LE,
  .rate = 44100,
  .channels = 1,
};

#define BUF_SIZE 0x2000

// y @ 0x00000c74
void mangle_complexes(double complex *complex_buf, size_t idx, uint32_t mask) {
  for(uint32_t i = 0; i < (mask + (mask >> 31)) >> 1; i++) {
    // TBD
  }
}

// Reverse the lowest 12 bits
// reverse_bits @ 0x00000a0a
size_t reverse_bits(size_t n) {
  size_t result = 0;

  for(uint bit = 0; bit < 13; bit++) {
    result |= (((1 << bit) & n) >> bit) << (12 - bit);
  }

  return result;
}

// bit_flip @ 0x00000a63
void bit_flip(float *in_buf, double complex *out_buf) {
  for(size_t i = 0; i < BUF_SIZE; i++) {
    float in_val = in_buf[i];
    size_t o = reverse_bits(i);

    out_buf[o] = (in_val + 0.0f * _Complex_I);
    //((float *)out_buf)[o * 2 + 0] = in_val;
    //((float *)out_buf)[o * 2 + 1] = 0.0;
  }
}

// x @ 0x00000e32
void convert_to_complex(float *record_buf, double complex *complex_buf) {
  bit_flip(record_buf, complex_buf);

  for(uint bit = 1; bit < 14; bit++) {
    uint32_t mask = 1 << bit;
    for(size_t i = 0; i < BUF_SIZE; i += mask) {
      //mangle_complexes(complex_buf, i, mask);
    }
  }
}

// Actually part of original function f (below)
size_t index_from_key(int key) {
  return (size_t)((key << 0xd) / 0xac44) * 2;
}

// f @ 0x00000ea8
double select_complex(double complex *complex_buf, int key) {
  return cabs(complex_buf[index_from_key(key)]);
}

// r @ 0x00000f0e
void check(uint64_t *checksum, double complex *complex_buf) {
  if((++ *(int *)checksum) < 21) {
    double set1[4] = {
      select_complex(complex_buf, 0x4b9),
      select_complex(complex_buf, 0x538),
      select_complex(complex_buf, 0x5c5),
      select_complex(complex_buf, 0x661),
    };

    uint32_t max_idx1 = -1;
    double max1 = 1.0;
    for(size_t i = 0; i < 4; i++) {
      if(set1[i] > max1) {
        max_idx1 = i;
        max1 = set1[i];
      }
    }

    double set2[4] = {
      select_complex(complex_buf, 0x2b9),
      select_complex(complex_buf, 0x302),
      select_complex(complex_buf, 0x354),
      select_complex(complex_buf, 0x3ad),
    };

    uint32_t max_idx2 = -1;
    double max2 = 1.0;
    for(size_t i = 0; i < 4; i++) {
      if(set2[i] > max2) {
        max_idx2 = i;
        max2 = set2[i];
      }
    }
  }
}

// SHOULD be -7.141592... (-pi - 4)
// That's what Ghidra says when I define the bytes as a float10 (80-bit)
// and that's what http://weitz.de/ieee/ gives for a 128-bit float
// but when I have my C code printf("%.20Lf\n", double_const.d);
// it prints out -6.28318530717958647703
// So I'm not sure what to think.
// I've left the literal bytes from 0x00100ca7 in the binary, but this is TODO
static union {
  long double d;
  uint8_t bytes[10];
} double_const;

void init_double_const() {
  double_const.bytes[0] = 0x35;
  double_const.bytes[1] = 0xc2;
  double_const.bytes[2] = 0x68;
  double_const.bytes[3] = 0x21;
  double_const.bytes[4] = 0xa2;
  double_const.bytes[5] = 0xda;
  double_const.bytes[6] = 0x0f;
  double_const.bytes[7] = 0xc9;
  double_const.bytes[8] = 0x01;
  double_const.bytes[9] = 0xc0;
}

// main @ 0x000011e8
int main(int argc, char **argv) {
  pa_simple *s;
  float record_buf[BUF_SIZE];
  double complex complex_buf[BUF_SIZE * 2];
  int error;
  int check_result = -1;
  uint32_t checksum;

  init_double_const();

  s = pa_simple_new(NULL, argv[0], PA_STREAM_RECORD, NULL, "record", &ss, NULL, NULL, &error);

  if(s == NULL) {
    fprintf(stderr, "pa_simple_new() faild: %s\n", pa_strerror(error));
    return 1;
  }

  do {
    int read_result = pa_simple_read(s, record_buf, sizeof(record_buf), &error);
    if(read_result < 0) {
      fprintf(stderr, "pa_simple_read() failed: %s\n", pa_strerror(error));
      return 1;
    }

    convert_to_complex(record_buf, complex_buf);
    // check_result = check(&checksum, complex_buf);
    // if(result < 0) {
    //   fprintf(stderr, "FAILED\n");
    //   return 1;
    // }
  } while(check_result != 0);

  fprintf(stderr, "SUCCESS\n");
  pa_simple_free(s);

  return 0;
}
