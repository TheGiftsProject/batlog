module Log
  class Engine < Rails::Engine
    isolate_namespace Log
  end
end