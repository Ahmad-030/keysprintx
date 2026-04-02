import 'dart:math';

class TypingTexts {
  static const _easy = [
    "The sun rises every morning to greet the world. Birds sing their sweet songs as the day begins. Children laugh and play in the warm golden light. Life is a beautiful gift we share together.",
    "A dog ran across the green park with joy. It jumped over the fence and wagged its tail. The kids laughed and clapped their hands with delight. Everyone smiled at the happy little dog.",
    "She opened the window to let in the fresh air. The smell of flowers drifted into the room. She took a deep breath and felt at peace. It was going to be a great day.",
    "Rain fell softly on the roof all night long. The sound made sleeping feel calm and easy. In the morning the streets were clean and bright. Everything smelled fresh after the rain.",
    "Tom loved to read books in the old library. The quiet space made it easy to think. He always found a new world inside every page. Books were his best friends in the world.",
  ];

  static const _medium = [
    "Flutter is Google's open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. It uses the Dart programming language and offers a rich set of pre-built widgets for creating beautiful, performant user interfaces with ease.",
    "Artificial intelligence is transforming the way we interact with technology, enabling machines to learn from experience and perform tasks that previously required human intelligence. From virtual assistants to autonomous vehicles, AI is reshaping industries and creating new possibilities every day.",
    "The scientific method involves forming hypotheses, conducting experiments, analyzing data, and drawing conclusions based on empirical evidence. This systematic approach has been the foundation of scientific progress for centuries and continues to drive innovation across all fields of study.",
    "Cloud computing has revolutionized how businesses store, process, and manage data. By leveraging remote servers accessed through the internet, organizations can scale their infrastructure dynamically, reduce operational costs, and improve collaboration across distributed teams.",
    "Programming languages serve as the bridge between human thought and machine execution. Each language has its own syntax, paradigms, and use cases. Choosing the right tool for your project can significantly impact development speed and application quality and maintainability.",
  ];

  static const _hard = [
    "Quantum entanglement describes how particles can become interconnected such that the quantum state of one particle instantaneously influences its partner, regardless of spatial separation between them, challenging our classical understanding of locality and causality in modern physics.",
    "Byzantine fault-tolerant consensus algorithms in distributed systems require careful consideration of network partitions, message delays, and adversarial nodes that may behave arbitrarily. Protocols like PBFT provide guarantees under specific assumptions about the fraction of faulty participants.",
    "Epigenetic modifications, including DNA methylation and histone acetylation, regulate gene expression without altering the underlying nucleotide sequence. These heritable changes in phenotype can be influenced by environmental factors with profound implications for developmental biology.",
    "Asymptotic analysis using Big-O notation provides a mathematical framework for evaluating computational efficiency as input size approaches infinity. Understanding polynomial versus exponential time complexities is fundamental to algorithm design and cryptographic security proofs.",
    "Neuroplasticity, the brain's remarkable ability to reorganize synaptic connections in response to experience and learning, underlies our capacity for skill acquisition, memory formation, and recovery from neurological injury. Recent advances in optogenetics enable researchers to manipulate specific neural circuits.",
  ];

  static String getRandom(int difficulty) {
    final list = difficulty == 0 ? _easy : difficulty == 2 ? _hard : _medium;
    return list[Random().nextInt(list.length)];
  }

  static List<String> get difficultyLabels => ['Easy', 'Medium', 'Hard'];
}