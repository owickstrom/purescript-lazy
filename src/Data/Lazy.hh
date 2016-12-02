#ifndef Data_Lazy_FFI_HH
#define Data_Lazy_FFI_HH

#include "PureScript/PureScript.hh"

namespace Data_Lazy {
  using namespace std;
  using namespace PureScript;

  class Lazy {
    public:
    std::function<any (any)> thunk;
    Lazy(function<any (any)> f) : thunk(f) {}
  };

  any defer(std::function<any (any)> thunk);

  any force(any a);
}

#endif
