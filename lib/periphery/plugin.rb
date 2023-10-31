# frozen_string_literal: true

module Danger
  # Checks a Periphery report to match files with unused code.
  #
  # @example See if your active files contain unused code
  #
  #          periphery.report("report.json")
  #
  # @see  RestlessThinker/danger-periphery
  # @tags periphery
  #
  class DangerPeriphery < Plugin
    def report(report_file)
      files = periphery(report_file)
      return if files.empty?

      markdown offenses_message(files)
    end

    private

    def periphery(report_file)
      require 'json'

      periphery_report_file = File.read(report_file)
      periphery_report_json = JSON.parse(periphery_report_file)
      active_files = (git.modified_files + git.added_files)

      periphery_files = Hash.new { |h, k| h[k] = [] }

      periphery_report_json.each do |entry|
        filename = File.basename(entry["location"].gsub(/:.*/, ""))
        periphery_files[filename] << entry
      end

      final_warnings = []

      active_files.any? do |filename|
        basename = File.basename(filename)
        if periphery_files.key?(basename)
          final_warnings << periphery_files[basename]
        end
      end

      return final_warnings
    end

    # Builds the message
    def offenses_message(offending_files)
      require 'terminal-table'

      message = "### Periphery Unused Code\n\n"
      table = Terminal::Table.new(
        headings: %w(File Name Kind Accessibility Module),
        style: { border_i: '|' },
        rows: offending_files.map do |file|
          [file['location'], file['name'], file['kind'], file['accessibility'], file['modules']]
        end
      ).to_s
      message + table.split("\n")[1..-2].join("\n")
    end
  end
end
