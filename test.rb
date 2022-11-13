require 'fileutils'
require 'timers'
require 'Time'
require 'active_support/time'

module MoveFile
    def do(fileName, moveToDirPath)
        fileObj = File::Stat::new(fileName)
        FileUtils::cp_r(fileName, moveToDirPath)
        File::utime(fileObj.atime, fileObj.mtime, "#{moveToDirPath}/#{fileName}")
    end
    module_function :do
end

class FileCheck
    include MoveFile

    def initialize(path = ".")
        unless path.is_a?(String) then
            exit
        end
        @files = Dir.foreach(path)
    end
    
    public
    def showFiles
        @files.each do |file|
            next if file == "." || file == ".."
        end
    end

    def doMoveFiles(moveToDirPath)
        @files.each do |file|
            next if file == "." || file == ".." || file == "mv"
            if isCreated24hAgo?(file) then
                MoveFile::do(file, moveToDirPath)
            end
        end
    end

    private
    def isCreated24hAgo?(filename)
        file = File::Stat::new(filename)
        if file.atime < Time::now::yesterday then
            return true
        else
            return false
        end
    end
end

if __FILE__ == $0 then
    moveToDirPath = ARGV[0]
    exit if moveToDirPath.nil? 
    exit if !(Dir.exist?(moveToDirPath) || File.directory?(moveToDirPath)) 

    timers = Timers::Group.new
    fc = FileCheck.new(".")
    timers.every(5) {
        puts "#{Time.now.strftime('%M:%S')}"
        timers.after(1) { puts "do"}
        fc.doMoveFiles(moveToDirPath)
    }
    loop { timers.wait }
end