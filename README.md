# MojoMath - Multiplication Table Practice Game 🎯

A fun and interactive multiplication table practice game built with Perl and Mojolicious framework. Perfect for grade school students learning their multiplication tables!

## Features

- 🎲 Random multiplication problems (1-10 range)
- 📊 Score tracking with percentage
- 🎨 Colorful, kid-friendly interface
- ✨ Instant feedback on answers
- 🔄 Easy score reset

## Prerequisites

- Perl 5.x
- Mojolicious framework

## Installation

1. Install Mojolicious:
```bash
cpan Mojolicious
```

Or using cpanm:
```bash
cpanm --installdeps .
```

## Running the Application

Start the development server:
```bash
perl mojomath.pl daemon
```

Or with morbo for auto-reload during development:
```bash
morbo mojomath.pl
```

Then open your browser and navigate to:
```
http://localhost:3000
```

## How to Play

1. A multiplication problem will be displayed (e.g., "7 × 8 = ?")
2. Type your answer in the input field
3. Click "Check Answer" or press Enter
4. Get instant feedback and see your score
5. Continue practicing with new random problems
6. Click "Reset Score" to start over

## For Parents and Teachers

- The game generates problems using numbers 1-10
- Scores are tracked per session
- The interface is designed to be engaging and encouraging for children
- All problems are randomly generated for varied practice

## License

This project is open source and available for educational purposes.
