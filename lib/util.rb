# returns the HTML at the provided path as a string
def html path
  get_file_as_string path
end

# gets the contents of the file at path as a string
def get_file_as_string path
  File.open(path, "r").read
end