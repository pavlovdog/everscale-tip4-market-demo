module.exports = {
    compiler: {
      // Path to https://github.com/broxus/TON-Solidity-Compiler
      /// For Local use:
      path: './../TON-Solidity-Compiler/build/solc/solc',
      /// For DevContainer use:
      // path: '/usr/bin/solc-ton'
    },
    linker: {
      // Path to https://github.com/tonlabs/TVM-linker
      /// For Local use:
      path: './../TVM-linker/tvm_linker/target/release/tvm_linker',
      /// For DevContainer use:
      // path: '/usr/bin/tvm_linker'
    },
    networks: {
      local: {
        ton_client: {
          network: {
            server_address: 'http://localhost/',
          },
        },
        giver: {
          address: '0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94',
          abi: { "ABI version": 1, "functions": [{ "name": "constructor", "inputs": [], "outputs": [] }, { "name": "sendGrams", "inputs": [{ "name": "dest", "type": "address" }, { "name": "amount", "type": "uint64" }], "outputs": [] }], "events": [], "data": [] },
          key: '',
        },
        keys: {
          phrase: '',
          amount: 20,
        }
      }
    }
  };
  