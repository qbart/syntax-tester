#pragma once

#include <functional>
#include <string>
#include <unordered_map>
#include <vector>

class Engine;
class Io;

namespace Test {

class App {
  using Map = std::unordered_map<int, std::string>;
  using Callback =
      std::function<void(int status, std::vector<std::string> &&strings)>;

public:
  struct Config {
    std::string name;
  };

public:
  App() = default;
  ~App() = default;
  App(App &&) = delete;
  explicit App(int);
  App(Config cfg) noexcept : cfg(cfg) {}

  constexpr int xx() { return 1; }

  // comments
  virtual void run(int a, int b, const std::string &) const;

private:
  Config cfg;
};
} // namespace Test
