# `preprod`

## Development

* install dependencies

  ```sh
  git clone https://github.com/varlogerr/toolbox.sh.vendor.git ./vendor/vendor
  cd ./vendor/vendor
  git checkout <latest-tag>
  cd -
  # initialize the project
  ./vendor/vendor/bin/vendor.sh --init .
  # install dependencies. after initialization
  # there will be only vendor itself as a dependency
  ./vendor/vendor/bin/vendor.sh
  ```
