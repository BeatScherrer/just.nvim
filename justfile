default:
  echo "hello from default"
  zsh -ic "echo 'test error' >&2"

build:
  echo "hello from build"

# this is just a comment
test arg1 arg2:
  echo "hello from test {{arg1}} {{arg2}}"
  sleep 2
  echo "error" >&2
  exit 1
