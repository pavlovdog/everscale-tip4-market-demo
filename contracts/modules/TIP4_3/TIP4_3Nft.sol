// ItGold.io Contracts (v1.0.0) 

pragma ton-solidity = 0.57.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../TIP4_1/TIP4_1Nft.sol';
import './interfaces/ITIP4_3NFT.sol';
import './Index.sol';


/// @title One of the required contracts of an TIP4-1(Non-Fungible Token Standard) compliant technology.
/// For detect what interfaces a smart contract implements used TIP-6.1 standard. ...
/// ... Read more here (https://github.com/nftalliance/docs/blob/main/src/Standard/TIP-6/1.md)
abstract contract TIP4_3Nft is TIP4_1Nft, ITIP4_3NFT {

    uint128 _indexDeployValue;
    uint128 _indexDestroyValue;
    TvmCell _codeIndex;

    constructor(
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex
    ) public {
        tvm.accept();

        _indexDeployValue = indexDeployValue;
        _indexDestroyValue = indexDestroyValue;
        _codeIndex = codeIndex;

        _supportedInterfaces[
            bytes4(tvm.functionId(ITIP4_3NFT.indexCode)) ^
            bytes4(tvm.functionId(ITIP4_3NFT.indexCodeHash)) ^
            bytes4(tvm.functionId(ITIP4_3NFT.resolveIndex)) 
        ] = true;

        _deployIndex();

    }

    function changeOwner(
        address newOwner, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) public virtual override onlyManager {
        _destructIndex(sendGasTo);
        super.changeOwner(newOwner, sendGasTo, callbacks);
        _deployIndex();
    }

    function _deployIndex() internal virtual view {
        TvmCell codeIndexOwner = _buildIndexCode(address(0), _owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: _indexDeployValue}(_collection);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(_collection, _owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: _indexDeployValue}(_collection);
    }

    function _destructIndex(address sendGasTo) internal virtual view {
        address oldIndexOwner = resolveIndex(address(0), _owner);
        IIndex(oldIndexOwner).destruct{value: _indexDestroyValue}(sendGasTo);
        address oldIndexOwnerRoot = resolveIndex(_collection, _owner);
        IIndex(oldIndexOwnerRoot).destruct{value: _indexDestroyValue}(sendGasTo);
    }
    
    function indexCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64} (_codeIndex);
    }

    function indexCodeHash() public view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64} tvm.hash(_codeIndex);
    }

    function resolveIndex(address collection, address owner) public view override responsible returns (address index) {
        TvmCell code = _buildIndexCode(collection, owner);
        TvmCell state = _buildIndexState(code, address(this));
        uint256 hashState = tvm.hash(state);
        index = address.makeAddrStd(0, hashState);
        return {value: 0, flag: 64} index;
    }

    function _buildIndexCode(
        address collection,
        address owner
    ) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store("nft");
        salt.store(collection);
        salt.store(owner);
        return tvm.setCodeSalt(_codeIndex, salt.toCell());
    }

    function _buildIndexState(
        TvmCell code,
        address nft
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Index,
            varInit: {_nft: nft},
            code: code
        });
    }

    function setIndexDeployValue(uint128 indexDeployValue) public onlyManager {
        tvm.rawReserve(msg.value, 1);
        _indexDeployValue = indexDeployValue;
        msg.sender.transfer({value: 0, flag: 128});
    }

    function setIndexDestroyValue(uint128 indexDestroyValue) public onlyManager {
        tvm.rawReserve(msg.value, 1);
        _indexDestroyValue = indexDestroyValue;
        msg.sender.transfer({value: 0, flag: 128});
    }

    function indexDeployValue() public view responsible returns(uint128) {
        return {value: 0, flag: 64} _indexDeployValue;
    }

    function indexDestroyValue() public view responsible returns(uint128) {
        return {value: 0, flag: 64} _indexDestroyValue;
    }

}