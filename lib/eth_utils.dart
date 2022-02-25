import 'package:dart_web3/dart_web3.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:walletconnect_dart/walletconnect_dart.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EthereumUtils {
  late http.Client httpClient;
  late Web3Client ethClient;

  final contractAddress =
      dotenv.env["FIRST_COIN_CONTRACT_ADDRESS"]; //TO read contract
  var privateKeyMeta = dotenv.env['METAMASK_PRIVATE_KEY'];

  void initialSetup() {
    httpClient = http.Client();
    String infura =
        "https://rinkeby.infura.io/v3/" + dotenv.env['INFURA_PROJECT_ID']!;

    ethClient = Web3Client(infura, httpClient);
  }

  //crate contract
  Future<DeployedContract> getDeployedContract(
      String contractAddress, Web3Client web3Client) async {
    contractAddress = contractAddress;
    ethClient = web3Client;
    String abi = await rootBundle.loadString("assets/contract.abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "FirstCoin"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  //get balance->read durch query(get contract)
  Future getBalance() async {
    List<dynamic> result = await query("getbalance", []);
    var myData = result[0];
    print('test3:');
    print(myData);
    return myData;
  }

  //withdra
  Future<String> withdrawCoin(double amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("withdra", [bigAmount]);
    print('test2:');
    print(response);
    return response;
  }

  //deposit
  Future<String> depositCoin(double amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("deposit", [bigAmount]);
    print('test3:');
    print(response);
    return response;
  }

  //get contract
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await getDeployedContract(contractAddress!, ethClient);
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    try {
      EthPrivateKey credential = EthPrivateKey.fromHex(privateKeyMeta!);

      DeployedContract contract =
          await getDeployedContract(contractAddress!, ethClient);
      final ethFunction = contract.function(functionName);
      final result = await ethClient.sendTransaction(
          //get result after user send transaction to blockchain
          credential,
          Transaction.callContract(
              contract: contract,
              function: ethFunction,
              parameters: args, //the value we send to blockchain
              maxGas: 100000),
          chainId: 4);
      return result; //return result of the transaction

    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
