import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TicTacToeHomePage(),
    );
  }
}

class TicTacToeHomePage extends StatefulWidget {
  @override
  _TicTacToeHomePageState createState() => _TicTacToeHomePageState();
}

class _TicTacToeHomePageState extends State<TicTacToeHomePage> {
  late List<List<String>> board;
  late String currentPlayer;
  late bool isGameOver;
  List<List<bool>> winCells = List.generate(3, (_) => List.generate(3, (_) => false));

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.generate(3, (_) => ''));
      currentPlayer = 'X';
      isGameOver = false;
      winCells = List.generate(3, (_) => List.generate(3, (_) => false));
    });
  }

  Future<void> aiMove() async {
    if (isGameOver) return;
    await Future.delayed(Duration(milliseconds: 500));
    
    int bestScore = -1000;
    int moveRow = -1, moveCol = -1;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == '') {
          board[row][col] = 'O';
          int score = minimax(board, 0, false);
          board[row][col] = '';

          if (score > bestScore) {
            bestScore = score;
            moveRow = row;
            moveCol = col;
          }
        }
      }
    }

    setState(() {
      board[moveRow][moveCol] = 'O';
      checkWinner();
      currentPlayer = 'X';
    });
  }

  int minimax(List<List<String>> b, int depth, bool isMaximizing) {
    String result = checkWinnerLocal(b);
    if (result == 'O') return 10 - depth;
    if (result == 'X') return depth - 10;
    if (result == 'Draw') return 0;

    int best = isMaximizing ? -1000 : 1000;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (b[row][col] == '') {
          b[row][col] = isMaximizing ? 'O' : 'X';
          int score = minimax(b, depth + 1, !isMaximizing);
          b[row][col] = '';
          best = isMaximizing ? best > score ? best : score : best < score ? best : score;
        }
      }
    }
    return best;
  }

  void handleTap(int row, int col) {
    if (board[row][col] == '' && !isGameOver && currentPlayer == 'X') {
      setState(() {
        board[row][col] = 'X';
      });
      checkWinner();
      if (!isGameOver) aiMove();
    }
  }

  void checkWinner() {
    String result = checkWinnerLocal(board);
    if (result != '') {
      setState(() => isGameOver = true);
    }
  }

  String checkWinnerLocal(List<List<String>> b) {
    for (int i = 0; i < 3; i++) {
      if (b[i][0] == b[i][1] && b[i][1] == b[i][2] && b[i][0] != '') {
        setState(() => winCells[i] = [true, true, true]);
        return b[i][0];
      }
      if (b[0][i] == b[1][i] && b[1][i] == b[2][i] && b[0][i] != '') {
        setState(() {
          winCells[0][i] = winCells[1][i] = winCells[2][i] = true;
        });
        return b[0][i];
      }
    }
    if (b[0][0] == b[1][1] && b[1][1] == b[2][2] && b[0][0] != '') {
      setState(() {
        winCells[0][0] = winCells[1][1] = winCells[2][2] = true;
      });
      return b[0][0];
    }
    if (b[0][2] == b[1][1] && b[1][1] == b[2][0] && b[0][2] != '') {
      setState(() {
        winCells[0][2] = winCells[1][1] = winCells[2][0] = true;
      });
      return b[0][2];
    }
    if (b.expand((row) => row).contains('')) return '';
    return 'Draw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tic-Tac-Toe - Play with AI')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            isGameOver ? (checkWinnerLocal(board) == 'Draw' ? 'Draw!' : '${checkWinnerLocal(board)} Wins!') : 'Turn: $currentPlayer',
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 20),
          Column(
            children: List.generate(3, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (col) {
                  return GestureDetector(
                    onTap: () => handleTap(row, col),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.all(5),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: winCells[row][col] ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          board[row][col],
                          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: resetGame,
            child: Text('Reset Game'),
          ),
        ],
      ),
    );
  }
}
