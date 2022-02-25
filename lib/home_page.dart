import 'package:dart_web3/dart_web3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:nft_app/custom_button.dart';
import 'package:nft_app/eth_utils.dart';
import 'package:nft_app/wallet_connect_ethereum.dart';

import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EthereumUtils ethUtils = EthereumUtils();

  double _value = 0.0;
  var _myData;
  var session;
  String account = "";
  var credentials;
  var yourContract;
  // String infura =
  //     "https://rinkeby.infura.io/v3/" + dotenv.env['INFURA_PROJECT_ID']!;
  var rpcUrl = 'https://rinkeby.infura.io/v3/b79e168db6e244aa8640993ac335edb3';

  final myAddress = dotenv.env['METAMASK_RINKEBY_WALLET_ADDRESS'];
  final contractAddress = "0xF80c7BAec986770939899Df442c7aB4f1Ee374A6";

  @override
  void initState() {
    super.initState();
    ethUtils.initialSetup();
    ethUtils.getBalance().then((data) {
      _myData = data;
      print(_myData);
      setState(() {});
    });
  }

  _walletConnect() async {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    // Subscribe to events
    connector.on('connect', (session) => print(session));
    connector.on('session_update', (payload) => print(payload));
    connector.on('disconnect', (session) => print(session));

    // Create a new session
    if (!connector.connected) {
      session = await connector.createSession(
          chainId: 4,
          onDisplayUri: (uri) async => {print(uri), await launch(uri)});
    }

    setState(() {
      account = session.accounts[0];
      print(account);
    });

    if (account != null) {
      print('account != null');
      final client = Web3Client(rpcUrl, Client());
      EthereumWalletConnectProvider provider =
          EthereumWalletConnectProvider(connector);
      credentials = WalletConnectEthereumCredentials(provider: provider);
      yourContract = ethUtils.getDeployedContract(contractAddress, client);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          'Test',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        )),
        body: SingleChildScrollView(
            child: Container(
                child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(20),
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(children: <Widget>[
                //Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Your balance:",
                      style: TextStyle(color: Colors.black38, fontSize: 18.0),
                    ),
                    _myData == null
                        ? const CircularProgressIndicator()
                        : Text(
                            "$_myData \ETH",
                            style: TextStyle(
                                fontSize: 25.0, color: Colors.blue.shade600),
                            textAlign: TextAlign.left,
                          ),
                  ],
                ),
                //slider
                SfSlider(
                  min: 0.0,
                  max: 10.0,
                  value: _value,
                  interval: 1,
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  stepSize: 1,
                  onChanged: (dynamic value) {
                    setState(() {
                      _value = value;
                      print(_value);
                    });
                  },
                ),
                Container(
                  child: Row(children: <Widget>[
                    CustomButton(
                        title: "refresh",
                        color: Colors.greenAccent,
                        onTapped: () async {
                          ethUtils.getBalance().then((data) => _myData = data);
                          setState(() {});
                          print("refresh");
                          print(_myData);
                          //   context
                          //       .read(ethUtilsNotifierProvider.notifier)
                          //       .getBalance();
                          // },
                        }),
                    CustomButton(
                        title: "deposit",
                        color: Colors.blueAccent,
                        onTapped: () async {
                          if (credentials == null) {
                            print('credentials == null');
                          } else {
                            var _depositReceipt =
                                await ethUtils.depositCoin(_value);
                            print("Deposit response: $_depositReceipt");
                            print("deposit");
                            print(_myData);

                            if (_value == 0) {
                              insertValidValue(context);
                              return;
                            } else {
                              showReceipt(context, "deposit", _depositReceipt);
                            }
                          }
                        }),
                    //
                    CustomButton(
                      title: "withdra",
                      color: Colors.pinkAccent,
                      onTapped: () async {
                        var _widthrawReceipt =
                            await ethUtils.withdrawCoin(_value);
                        print("Withdraw response: $_widthrawReceipt");
                        if (_value == 0) {
                          insertValidValue(context);
                          return;
                        } else {
                          showReceipt(context, "withdraw", _widthrawReceipt);
                        }
                      },
                    ),
                  ]),
                  margin: const EdgeInsets.all(20.0),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white24,
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(
                            fontSize: 22, fontFamily: 'Poppins'),
                      ),
                      onPressed: () async => _walletConnect(),
                      child: const Text('Connect Wallet'),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              ])),
        ))));
  }
}

insertValidValue(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          title: const Text(
            'Not allowed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18.0,
            ),
          ),
          content: const Text('Please insert a \nvalue different from 0!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
              )),
          actions: [
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

showReceipt(BuildContext context, String text, String receipt) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Thank you for submiting a $text",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 18.0,
              ),
            ),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Use the transaction hash bellow to check if it was successful",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Raleway',
                      color: Colors.blueGrey.shade600),
                ),
                Text(receipt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

// showCanceledTransaction(BuildContext context) {
//   return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white.withOpacity(0.8),
//           title: const Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Text(
//               'there was some problem with the transaction',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontFamily: 'Raleway', fontSize: 18.0),
//             ),
//           ),
//           content: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.3,
//             width: MediaQuery.of(context).size.height * 0.3,
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     "Are you sure that your balance is enough to allow transaction",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontFamily: 'Raleway',
//                         fontSize: 16.0,
//                         color: Colors.blueGrey.shade600),
//                   ),
//                 ]),
//           ),
//           actions: [
//             ElevatedButton(
//               child: const Text('Ok'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       });
// }
