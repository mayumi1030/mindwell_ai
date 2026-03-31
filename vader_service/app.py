from flask import Flask, request, jsonify
from flask_cors import CORS
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import nltk
import re

app = Flask(__name__)
CORS(app)

# Download NLTK data on startup
nltk.download('punkt', quiet=True)
nltk.download('stopwords', quiet=True)

analyzer = SentimentIntensityAnalyzer()

def get_sentiment_label(compound_score):
    """Convert compound score to label."""
    if compound_score >= 0.05:
        return 'POSITIVE'
    elif compound_score <= -0.05:
        return 'NEGATIVE'
    else:
        return 'NEUTRAL'

def get_sentiment_emoji(compound_score):
    """Get emoji for sentiment."""
    if compound_score >= 0.5:
        return '😊'
    elif compound_score >= 0.05:
        return '🙂'
    elif compound_score <= -0.5:
        return '😔'
    elif compound_score <= -0.05:
        return '😐'
    else:
        return '😶'

def extract_keywords(text, max_keywords=5):
    """Extract simple keywords from text."""
    # Remove punctuation and lowercase
    words = re.findall(r'\b[a-zA-Z]{4,}\b', text.lower())
    # Common stopwords to filter
    stopwords = {
        'this', 'that', 'with', 'have', 'from', 'they',
        'will', 'been', 'were', 'their', 'what', 'when',
        'which', 'your', 'just', 'also', 'very', 'about',
        'feel', 'feeling', 'today', 'really', 'think'
    }
    keywords = [w for w in words if w not in stopwords]
    # Return unique keywords
    seen = set()
    unique = []
    for k in keywords:
        if k not in seen:
            seen.add(k)
            unique.append(k)
    return unique[:max_keywords]

@app.route('/analyze', methods=['POST'])
def analyze():
    """Analyze sentiment of journal text."""
    data = request.get_json()

    if not data or 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400

    text = data['text'].strip()

    if not text:
        return jsonify({'error': 'Empty text'}), 400

    if len(text) > 5000:
        return jsonify({'error': 'Text too long (max 5000 chars)'}), 400

    # Run VADER analysis
    scores = analyzer.polarity_scores(text)
    compound = scores['compound']
    label = get_sentiment_label(compound)
    emoji = get_sentiment_emoji(compound)
    keywords = extract_keywords(text)

    return jsonify({
        'label': label,
        'emoji': emoji,
        'compound': round(compound, 4),
        'positive': round(scores['pos'], 4),
        'negative': round(scores['neg'], 4),
        'neutral': round(scores['neu'], 4),
        'keywords': keywords
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok', 'service': 'MindWell VADER'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)