default:
  echo "hello from default"
  zsh -ic "echo 'test error' >&2"

build:
  echo "hello from build"

test:
  echo "hello from test"

lint: 
  echo "hello from lint"
