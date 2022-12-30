default:
  echo "hello from default"
  zsh -ic "echo 'test error' >&2"

build:
  echo "hello from build"

test test_arg:
  echo "hello from test {{test_arg}}"

lint: 
  echo "hello from lint"
