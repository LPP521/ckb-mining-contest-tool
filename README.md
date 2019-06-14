# CKB Mining Contest Tool


## Run

```
$ curl -O -L https://github.com/nervosnetwork/ckb/releases/download/v0.13.0/ckb_v0.13.0_x86_64-apple-darwin.zip
$ unzip ckb_v0.13.0_x86_64-apple-darwin.zip && cd ckb_v0.13.0_x86_64-apple-darwin

$ export CKB_DIR="$(pwd)"
$ cd ../ && git clone https://github.com/cezres/ckb-mining-contest-tool && cd ./ckb-mining-contest-tool

$ swift build
$ ./.build/Debug/mining-contest-tool
```


[Nervos CKB Testnet Mining Competition](https://mineyourownbusiness.nervos.org/)
