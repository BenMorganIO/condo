if System.get_env("CI") do
  ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
end

ExUnit.start()
