import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

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
  bool isPlayingWithAI = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    resetGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.generate(3, (_) => ''));
      currentPlayer = 'X';
      isGameOver = false;
      _confettiController.stop();
    });
  }

  String checkWinner() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != '') return board[i][0];
      if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != '') return board[0][i];
    }
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != '') return board[0][0];
    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != '') return board[0][2];
    if (board.expand((e) => e).contains('')) return '';
    return 'Draw';
  }

  void aiMove() {
    if (isGameOver || !isPlayingWithAI) return;

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
      currentPlayer = 'X';
      String result = checkWinner();
      if (result != '') endGame(result);
    });
  }

  int minimax(List<List<String>> b, int depth, bool isMaximizing) {
    String result = checkWinner();
    if (result == 'O') return 10 - depth;
    if (result == 'X') return depth - 10;
    if (result == 'Draw') return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (b[row][col] == '') {
            b[row][col] = 'O';
            int score = minimax(b, depth + 1, false);
            b[row][col] = '';
            best = max(best, score);
          }
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (b[row][col] == '') {
            b[row][col] = 'X';
            int score = minimax(b, depth + 1, true);
            b[row][col] = '';
            best = min(best, score);
          }
        }
      }
      return best;
    }
  }

  void handleTap(int row, int col) {
    if (board[row][col] == '' && !isGameOver) {
      setState(() {
        board[row][col] = currentPlayer;
        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
      });

      String result = checkWinner();
      if (result != '') endGame(result);
      else if (isPlayingWithAI && currentPlayer == 'O') aiMove();
    }
  }

  void endGame(String result) {
    setState(() {
      isGameOver = true;
      if (result != 'Draw') _confettiController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tic-Tac-Toe - Play with AI or Player')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
                Text(
                  isGameOver ? (checkWinner() == 'Draw' ? 'Draw!' : '${checkWinner()} Wins! 🎉') : 'Turn: $currentPlayer',
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
                          child: Container(
                            margin: EdgeInsets.all(5),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => isPlayingWithAI = !isPlayingWithAI),
                  child: Text(isPlayingWithAI ? 'Play with Human' : 'Play with AI'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
