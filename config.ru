# This file is used by Rack-based servers to start the application.

ENV['TMPDIR'] ||= 'tmp'

require ::File.expand_path('../config/environment',  __FILE__)
run CapellaJuris::Application
