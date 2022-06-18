task :fin => :dep do
  puts "finished"
end

task :default => [:fin]

task :dep do
  puts "run sync"
  require './lib/cli'
  MyCLI.start(['sync'])
end
