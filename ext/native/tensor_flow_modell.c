#include "tensor_flow_modell.h"

static VALUE TensorFlowModellKlasse = Qnil;

typedef struct {} TensorFlowModellData;

static void TensorFlowModellData_free(void* const ptr) {
  TensorFlowModellData* const data = ptr;
  free(data);
}

static size_t TensorFlowModellData_size(const void* const ptr) {
  return sizeof(TensorFlowModellData);
}

const rb_data_type_t TensorFlowModellData_type = {
  "Native::TensorFlowModellData",
  {NULL, TensorFlowModellData_free, TensorFlowModellData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static VALUE TensorFlowModell_alloc(const VALUE klasse) {
  TensorFlowModellData* data;
  const VALUE objekt = TypedData_Make_Struct(klasse, TensorFlowModellData, &TensorFlowModellData_type, data);
  return objekt;
}

static VALUE TensorFlowModell_initialize(const VALUE self) {
  return self;
}

static VALUE TensorFlowModell_bewerte(const VALUE self, const VALUE ai_input) {
  rb_raise(rb_eNotImpError, "Bewerte ist noch nicht implementiert.");
}

static VALUE TensorFlowModell_merke(const VALUE self, const VALUE ai_input, const VALUE bewertung, const VALUE alter_ai_input, const VALUE ai_aktionen) {
  rb_raise(rb_eNotImpError, "Merke ist noch nicht implementiert.");
}

void init_tensor_flow_modell_klasse_unter(const VALUE modul) {
  TensorFlowModellKlasse = rb_define_class_under(modul, "TensorFlowModell", rb_cObject);
  rb_define_alloc_func(TensorFlowModellKlasse, TensorFlowModell_alloc);
  rb_define_method(TensorFlowModellKlasse, "initialize", TensorFlowModell_initialize, 0);
  rb_define_method(TensorFlowModellKlasse, "merke", TensorFlowModell_merke, 4);
  rb_define_method(TensorFlowModellKlasse, "bewerte", TensorFlowModell_bewerte, 1);
}















