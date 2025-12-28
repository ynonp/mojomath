#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

# In-memory session storage for score tracking
my %sessions;

# Helper to generate a new multiplication problem
helper new_problem => sub ($c) {
    my $num1 = int(rand(10)) + 1;  # 1-10
    my $num2 = int(rand(10)) + 1;  # 1-10
    return {
        num1 => $num1,
        num2 => $num2,
        answer => $num1 * $num2
    };
};

# Helper to get or create session
helper get_session => sub ($c) {
    my $sid = $c->session('sid');
    unless ($sid && $sessions{$sid}) {
        # Use Mojolicious built-in session which is cryptographically secure
        $sid = $c->session->{sid} // do {
            my $new_sid = join('', map { sprintf('%02x', int(rand(256))) } 1..16);
            $c->session(sid => $new_sid);
            $new_sid;
        };
        $sessions{$sid} = {
            score => 0,
            total => 0
        };
    }
    return $sessions{$sid};
};

# Main page - show the game
get '/' => sub ($c) {
    my $session = $c->get_session;
    my $problem = $c->new_problem;
    
    $c->session(current_problem => $problem);
    
    $c->render(
        template => 'index',
        num1 => $problem->{num1},
        num2 => $problem->{num2},
        score => $session->{score},
        total => $session->{total},
        message => undef,
        correct => 0
    );
};

# Check answer and show result
post '/check' => sub ($c) {
    my $session = $c->get_session;
    my $user_answer = $c->param('answer');
    my $problem = $c->session('current_problem');
    
    my $correct = 0;
    my $message = '';
    
    if (defined $user_answer && $user_answer =~ /^\d+$/) {
        $session->{total}++;
        if ($user_answer == $problem->{answer}) {
            $session->{score}++;
            $correct = 1;
            $message = 'Correct! 🎉';
        } else {
            $message = "Not quite. The answer is $problem->{answer}. Try the next one!";
        }
    } else {
        $message = 'Please enter a number!';
    }
    
    # Generate new problem for next round
    my $new_problem = $c->new_problem;
    $c->session(current_problem => $new_problem);
    
    $c->render(
        template => 'index',
        num1 => $new_problem->{num1},
        num2 => $new_problem->{num2},
        score => $session->{score},
        total => $session->{total},
        message => $message,
        correct => $correct
    );
};

# Reset score
post '/reset' => sub ($c) {
    my $session = $c->get_session;
    $session->{score} = 0;
    $session->{total} = 0;
    $c->redirect_to('/');
};

app->start;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head>
    <title>Multiplication Practice</title>
    <style>
        body {
            font-family: 'Comic Sans MS', 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 500px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            text-align: center;
            margin-top: 0;
            font-size: 2.5em;
        }
        .score {
            background: #f0f0f0;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 20px;
            font-size: 1.2em;
        }
        .score-correct {
            color: #22c55e;
            font-weight: bold;
        }
        .score-total {
            color: #667eea;
            font-weight: bold;
        }
        .problem {
            font-size: 3em;
            text-align: center;
            color: #333;
            margin: 30px 0;
            font-weight: bold;
        }
        .answer-input {
            width: 100%;
            padding: 15px;
            font-size: 2em;
            border: 3px solid #667eea;
            border-radius: 10px;
            text-align: center;
            box-sizing: border-box;
            margin-bottom: 20px;
        }
        .answer-input:focus {
            outline: none;
            border-color: #764ba2;
            box-shadow: 0 0 10px rgba(118, 75, 162, 0.3);
        }
        .button {
            width: 100%;
            padding: 15px;
            font-size: 1.5em;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: bold;
            transition: background 0.3s;
        }
        .button:hover {
            background: #764ba2;
        }
        .button:active {
            transform: scale(0.98);
        }
        .reset-button {
            background: #94a3b8;
            margin-top: 10px;
            font-size: 1em;
            padding: 10px;
        }
        .reset-button:hover {
            background: #64748b;
        }
        .message {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
            font-size: 1.3em;
            font-weight: bold;
        }
        .message-correct {
            background: #dcfce7;
            color: #166534;
            border: 2px solid #22c55e;
        }
        .message-incorrect {
            background: #fee2e2;
            color: #991b1b;
            border: 2px solid #ef4444;
        }
        .message-info {
            background: #dbeafe;
            color: #1e40af;
            border: 2px solid #3b82f6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎯 Multiplication Practice! 🎯</h1>
        
        <div class="score">
            Score: <span class="score-correct"><%= $score %></span> / <span class="score-total"><%= $total %></span>
            % if ($total > 0) {
                (<%= sprintf("%.0f", ($score / $total) * 100) %>%)
            % }
        </div>
        
        % if (defined $message) {
            <div class="message <%= $correct ? 'message-correct' : 'message-incorrect' %>">
                <%= $message %>
            </div>
        % }
        
        <div class="problem">
            <%= $num1 %> × <%= $num2 %> = ?
        </div>
        
        <form method="POST" action="/check">
            <input 
                type="number" 
                name="answer" 
                class="answer-input" 
                placeholder="Your answer" 
                autofocus 
                required
            />
            <button type="submit" class="button">Check Answer ✓</button>
        </form>
        
        <form method="POST" action="/reset">
            <button type="submit" class="reset-button button">Reset Score 🔄</button>
        </form>
    </div>
    
    <script>
        // Auto-focus on the input field after page load
        document.addEventListener('DOMContentLoaded', function() {
            const input = document.querySelector('.answer-input');
            if (input) {
                input.focus();
                input.select();
            }
        });
    </script>
</body>
</html>
