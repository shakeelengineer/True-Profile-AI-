import re

def preprocess_text(text):
    """Bias Reduction: Removes Emails/Phone to focus on merit while preserving structure."""
    text = re.sub(r'\S+@\S+', '[EMAIL_REMOVED]', text)
    text = re.sub(r'\+?\d[\d -]{8,12}\d', '[PHONE_REMOVED]', text)
    # Clean up horizontal whitespace but preserve newlines
    text = re.sub(r'[ \t]+', ' ', text)
    return text.strip()

def clean_for_nlp(text):
    text = re.sub(r'\S+@\S+', '', text)
    text = re.sub(r'\+?\d[\d -]{8,12}\d', '', text)
    return text.strip()
