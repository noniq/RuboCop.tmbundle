require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

class RubocopRunner
  attr_reader :base_dir

  def initialize
    Dir.chdir(ENV['TM_PROJECT_DIRECTORY'])
  end

  # Run RuboCop for the given single file or Array of files. `script_args` can be used to pass additional command line options to
  # RuboCop.
  #
  # If a block is given, it will be passed the number detected offenses (or false if no rubocop executable was found).
  def run(file_or_files, script_args = [])
    return unless file_or_files
    files = Array(file_or_files)
    executable, options = find_rubocop_executable
    if executable.nil?
      yield false if block_given?
    else
      options = {
        :script_args => %w(--format clang --display-cop-names) + script_args,
        :verb => 'Linting',
        :noun => files.size == 1 ? File.basename(files[0]) : "#{files.size} selected files",
        :use_hashbang => false,
        :version_replace => 'RuboCop \1'
      }.merge(options)
      detected_offenses = nil
      TextMate::Executor.run(executable, files, options) do |line, _type|
        detected_offenses = $1.to_i if line =~ /(\d+|no) offenses? detected/
        nil # Always return nil so that TextMate::Executor parses the output, too.
      end
      yield detected_offenses if block_given?
    end
  end

  # Like `#run`, but RuboCop will be run in the background (detached) to avoid blocking TextMate’s UI.
  def run_in_background(file_or_files, script_args = [], &block)
    pid = fork do
      STDOUT.reopen(open('/dev/null', 'w'))
      STDERR.reopen(open('/dev/null', 'w'))
      run(file_or_files, script_args, &block)
    end
    Process.detach(pid)
  end

  private

  def find_rubocop_executable
    if File.exist?('bin/rubocop')
      ['bin/rubocop', {}]
    elsif File.exist?('Gemfile.lock') && !File.readlines('Gemfile.lock').grep(/^    rubocop/).empty?
      [%w(bundle exec rubocop), {:version_args => %w(exec rubocop --version)}]
    elsif system('which -s rbenv && rbenv which rubocop &>/dev/null')
      ['rubocop', {}]
    end
  end
end
