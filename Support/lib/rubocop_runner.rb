require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/executor"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

class RubocopRunner
  attr_reader :base_dir

  def initialize
    Dir.chdir(ENV['TM_PROJECT_DIRECTORY'])
  end

  def run(file_or_files)
    return unless file_or_files
    files = Array(file_or_files)
    executable, options = find_rubocop_executable
    if executable
      options = {
        :script_args => %w(--format clang),
        :verb => 'Linting',
        :noun => files.size == 1 ? File.basename(files[0]) : "#{files.size} selected files",
        :use_hashbang => false,
        :version_replace => 'RuboCop \1'
      }.merge(options)
      TextMate::Executor.run(executable, files, options) do |line, _type|
        if line =~ /(\d+) offenses? detected/
          TextMate::UI.tool_tip(Regexp.last_match(0)) if Regexp.last_match(1).to_i > 0
        end
        nil # Always return nil so that TextMate::Executor parses the output, too.
      end
    else
      buttons = ['OK', 'Open Installation Instructions']
      btn = TextMate::UI.alert(:critical, 'Rubocop not found', 'You need to install RuboCop first.', *buttons)
      system('open "http://rubocop.readthedocs.io/en/latest/installation/"') if btn == buttons[1]
    end
  end

  def run_in_background(file_or_files)
    pid = fork do
      STDOUT.reopen(open('/dev/null', 'w'))
      STDERR.reopen(open('/dev/null', 'w'))
      run(file_or_files)
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
