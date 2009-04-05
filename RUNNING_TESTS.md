# Running Tests


## Geminstaller

Make sure you have the latest versions of all dependencies, make sure you have geminstaller installed with:

    sudo gem install geminstaller
    
Then run

    sudo geminstaller

## Installing rails for the tests

Before running tests for the first time, run:

    rake install_dependencies

To refresh the rails versions (pull from the rails github repo and refresh the symlinks), run:

    rake refresh_rails_versions

## Run the specs
    
To run the specs, execute:

    rake spec
    
Running `spec spec` will _not_ work, because that will attempt to run all files that end in \_spec within the spec directory, which includes the entire rails repository.