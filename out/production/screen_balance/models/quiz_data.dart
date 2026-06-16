class Option {
  final String text;
  final String archetypeScore;

  const Option(this.text, this.archetypeScore);
}

class Question {
  final int id;
  final String text;
  final List<Option> options;

  const Question(this.id, this.text, this.options);
}

class QuizData {
  static const List<Question> questions = [
    Question(
      1,
      "When you pick up your phone, how often do you know exactly why you unlocked it?",
      [
        Option("Almost always. I have a specific purpose.", "None"),
        Option("About half the time.", "The Phantom Checker"),
        Option("Rarely. It's mostly muscle memory.", "The Phantom Checker"),
        Option("I don't know, it just ends up in my hand.", "The Doomscroller"),
      ],
    ),
    Question(
      2,
      "How soon after waking up do you usually check social media, news, or emails?",
      [
        Option("Immediately, while still in bed.", "The Morning Scroller"),
        Option("Within the first 15-30 minutes.", "The Morning Scroller"),
        Option("While eating breakfast.", "The Task Avoidant"),
        Option("Not until I'm fully ready for the day.", "None"),
      ],
    ),
    Question(
      3,
      "Do you find yourself endlessly scrolling in bed, knowing you should be sleeping?",
      [
        Option("Yes, almost every night.", "The Evening Escapist"),
        Option("Sometimes, when I've had a stressful day.", "The Evening Escapist"),
        Option("Only if I can't sleep anyway.", "The Doomscroller"),
        Option("Never, I put my phone away before bed.", "None"),
      ],
    ),
    Question(
      4,
      "Around 2-3 PM, do you reach for short-form video to fight off a drop in energy?",
      [
        Option("Yes, I need the dopamine hit to stay awake.", "The Midday Slumper"),
        Option("Sometimes, just for a quick break.", "The Midday Slumper"),
        Option("I check messages, but not videos.", "The Notification Reactive"),
        Option("No, I take a walk or drink water instead.", "None"),
      ],
    ),
    Question(
      5,
      "If you face a difficult or boring task, does your app-switching suddenly increase?",
      [
        Option("Absolutely. I constantly look for distractions.", "The Task Avoidant"),
        Option("Yes, I tend to open a few other tabs or apps.", "The Task Avoidant"),
        Option("Only if I get completely stuck.", "The Doomscroller"),
        Option("No, I usually power through.", "None"),
      ],
    ),
    Question(
      6,
      "How often do you unlock your phone in an elevator or line, purely out of muscle memory?",
      [
        Option("Every single time. I can't just stand there.", "The Phantom Checker"),
        Option("Frequently. It feels awkward otherwise.", "The Social Comparer"),
        Option("Sometimes, if the wait is long.", "The Phantom Checker"),
        Option("Rarely. I don't mind the downtime.", "None"),
      ],
    ),
    Question(
      7,
      "When a notification pops up, how hard is it for you to ignore it and keep working?",
      [
        Option("Impossible. I have to check it immediately.", "The Notification Reactive"),
        Option("Very hard, I usually check it within a minute.", "The Notification Reactive"),
        Option("I can ignore it if I'm busy, but it's distracting.", "The Social Comparer"),
        Option("Easy. I keep my phone on DND anyway.", "None"),
      ],
    ),
    Question(
      8,
      "Do you ever read negative news or endless feeds until you feel tense or 'zoned out'?",
      [
        Option("Yes, frequently. I can't stop scrolling.", "The Doomscroller"),
        Option("Sometimes, especially late at night.", "The Doomscroller"),
        Option("Rarely, I try to curate my feeds.", "The Social Comparer"),
        Option("Never. I avoid negative content.", "None"),
      ],
    ),
    Question(
      9,
      "After using specific apps, do you frequently feel drained, envious, or 'less than'?",
      [
        Option("Yes, social media usually makes me feel this way.", "The Social Comparer"),
        Option("Sometimes, if I see everyone else succeeding.", "The Social Comparer"),
        Option("Only occasionally.", "The Evening Escapist"),
        Option("No, I use apps that inspire or connect me.", "None"),
      ],
    ),
    Question(
      10,
      "If we could help you reclaim one thing, would you choose 'More Focus', 'Better Sleep', or 'Less Anxiety'?",
      [
        Option("More Focus.", "The Task Avoidant"),
        Option("Better Sleep.", "The Evening Escapist"),
        Option("Less Anxiety.", "The Doomscroller"),
        Option("I just want to be more present.", "The Phantom Checker"),
      ],
    ),
  ];
}
