require 'json'
require 'httparty'

module LicenseFinder
  class Pip < PackageManager
    def current_packages
      output = `#{LicenseFinder::BIN_PATH.join("license_finder_pip.py")}`
      JSON(output).map do |package|
        PipPackage.new(
          package["name"],
          package["version"],
          File.join(package["location"], package["name"]),
          pypi_def(package["name"], package["version"]),
          logger: logger
        )
      end
    end

    private

    def package_path
      project_path.join('requirements.txt')
    end

    def pypi_def(name, version)
      response = HTTParty.get("https://pypi.python.org/pypi/#{name}/#{version}/json")
      if response.code == 200
        JSON.parse(response.body).fetch("info", {})
      else
        {}
      end
    end
  end
end
