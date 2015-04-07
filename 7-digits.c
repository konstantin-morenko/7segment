#include "7-digits.h"

short unsigned int digitize(short unsigned int digit) {
  switch(digit) {
  case 0: return SYM_0;
  case 1: return SYM_1;
  case 2: return SYM_2;
  case 3: return SYM_3;
  case 4: return SYM_4;
  case 5: return SYM_5;
  case 6: return SYM_6;
  case 7: return SYM_7;
  case 8: return SYM_8;
  case 9: return SYM_9;
  }
  return digit;
}
