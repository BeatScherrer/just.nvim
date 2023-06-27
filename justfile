default:
  echo "hello from default"
  zsh -ic "echo 'test error' >&2"

build:
  echo "hello from build"

# this is just a comment
test test_arg:
  echo "hello from test {{test_arg}}"
  sleep 2
  echo "error" >&2
  exit 1
