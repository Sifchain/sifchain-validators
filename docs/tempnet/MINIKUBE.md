# Local Dev Environment

## Prequisites:
```
install docker for mac
```

```
brew install minikube jq go pwgen
```

```
brew install --cask virtualbox
```

```
make install
```

```
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin
```


## deploying local environment
```
  Usage: ./scripts/tempnet/launch.sh [OPTIONS]

  Options:
  -h      This help output.
  -c      Chain ID for sifnoded.
  -d      Chain ID for gaiad.
  -m      Moniker for sifnoded.
  -o      Moniker for gaiad.
  -i      Docker image tag for sifnoded.
  -j      Docker image tag for gaiad.
  -n      Namespace to deploy into.
```

```
./launch.sh -c lance-test-local -d lance-test-local -m lance-test-local -o lance-test-local -i develop -j 5.0.5 -n lance
```