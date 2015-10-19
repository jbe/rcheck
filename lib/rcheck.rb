
require 'rcheck/version'
require 'rcheck/errors'
require 'rcheck/colors'
require 'rcheck/assertions'
require 'rcheck/debugging'
require 'rcheck/suite'
require 'rcheck/dsl'
require 'rcheck/progress_printer'
require 'rcheck/report_printer'
require 'rcheck/config'

# TODO:
# - instafail suite and children on errors
# - soft exception helper
# - alternative numbers when instafailed
# - formatters: numbers, tree, list
# - more / better assertions

module RCheck
  self.colors             = :default
  self.progress_printers  = %i(ProgressBar)
  self.report_printers    = %i(RedList ExpandedFailTree Numbers)

  ROOT_SUITE = Suite.new(nil)

  class << self
    def all() RCheck::ROOT_SUITE end
    extend Forwardable
    def_delegators(:all,    *%i(suite [] report!))
    def_delegators(:'RCheck::Colors', *%i(show_legend))

    def require_all(*globs)
      globs.map { |glob| Dir[glob] }.flatten.each do |path|
        rel  = File.join File.dirname(path), File.basename(path, '.*')
        full = File.expand_path(rel)
        require full
      end
    end
  end
end

