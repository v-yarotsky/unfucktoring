require 'rake/testtask'

Rake::TestTask.new(:unit) do |t|
  t.libs << "test"
  t.test_files = FileList['test/lib/**/test*.rb']
end

Rake::TestTask.new(:acceptance) do |t|
  t.libs << "test"
  t.test_files = FileList['test/acceptance/**/test*.rb']
end

task :default => [:unit, :acceptance]
