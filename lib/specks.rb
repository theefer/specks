require 'yaml'
require 'fileutils'

# usage: specks [module]
class Specks

  DOT_ROOT = File.join(ENV["HOME"], '.dot')
  MODULES_DIR = "#{DOT_ROOT}/modules"
  EXPORTS_DIR = "#{DOT_ROOT}/.exports"

  def run_one(mod)

    recipe_path = "#{MODULES_DIR}/#{mod}/recipe.yml"
    if File.exists?(recipe_path)
      recipe = YAML.load_file(recipe_path)

      comment = recipe[:comment] || '#'

      (recipe[:export] || {}).each do |file|
        export mod, file, comment
      end

      (recipe[:symlink] || {}).each do |file, dest|
        export mod, file, comment
        symlink mod, file, dest
      end

      (recipe[:inject] || {}).each do |file, dest|
        inject mod, file, dest, comment
      end

    else
      puts "No recipe.yml for #{mod}, skipping"
    end

  end

  def run_all
    modules = Dir.entries(MODULES_DIR).reject {|e| e == '.' || e == '..'}
    modules.each {|name| run_one(name)}
  end

  private

    def bannerise(source, mod, file, action, comment)
      "#{comment} -- [specks:start #{action} #{file}] --\n" +
        "#{source.chomp}\n" +
        "#{comment} -- [specks:end #{action} #{file}] --\n"
    end

    def export(mod, file, comment)
      FileUtils.mkdir_p("#{EXPORTS_DIR}/#{mod}") unless File.exists?("#{EXPORTS_DIR}/#{mod}")

      puts "Exporting #{file} for #{mod}"
      if File.directory?("#{MODULES_DIR}/#{mod}/#{file}")
        # TODO: no banner?
        FileUtils.cp_r("#{MODULES_DIR}/#{mod}/#{file}",
          "#{EXPORTS_DIR}/#{mod}/#{file}")
      else
        source = File.read("#{MODULES_DIR}/#{mod}/#{file}")
        File.open("#{EXPORTS_DIR}/#{mod}/#{file}", 'w') do |f|
          # TODO: run through erb ?
          # add banner at the beginning and end
          bannered = bannerise(source, mod, file, 'export', comment)
          f.write(bannered)
        end
      end
    end

    def symlink(mod, file, dest)
      dest_path = File.expand_path(dest)
      if File.exists?(dest_path) && ! File.symlink?(dest_path)
        # TODO: iff ! symlink pointing to the same place
        puts "Skipping symlinking to #{dest}, file exists"
      else
        # TODO: check if file pristine, i.e. nothing before/after banner
        puts "Symlink #{file} for #{mod} to #{dest}"

        FileUtils.mkdir_p File.dirname(dest_path)
        FileUtils.rm_rf(dest_path)
        FileUtils.ln_s("#{EXPORTS_DIR}/#{mod}/#{file}",
          dest_path)
      end
    end

    def inject(mod, file, dest, comment)
      dest_path = File.expand_path(dest)
      content = File.read("#{MODULES_DIR}/#{mod}/#{file}")

      bannered = bannerise(content, mod, file, 'inject', comment)

      # TODO: open dest, look for banner
      # TODO: if none, inject with banner
      # TODO: if found, replace within banner

      puts "Inject #{file} for #{mod} in #{dest}"
      File.open(dest_path, 'w') do |f|
        f.write(bannered)
      end
    end
end
