#include "Lazy.hh"

namespace Data_Lazy {
  using namespace std;
  using namespace PureScript;
  using namespace Data_Lazy;

  any defer(std::function<any (any)> thunk) {
    return make_managed<Lazy>(thunk);
  }

  any force(any a) {
    auto& lazy = cast<Lazy>(a);
    return lazy.thunk(unit);
  }
}
