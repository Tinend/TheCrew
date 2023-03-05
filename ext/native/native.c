#include <ruby.h>

#include "tensor_flow_modell.h"

VALUE NativeModul = Qnil;

void Init_native() {
  NativeModul = rb_define_module("Native");
  init_tensor_flow_modell_klasse_unter(NativeModul);
}
