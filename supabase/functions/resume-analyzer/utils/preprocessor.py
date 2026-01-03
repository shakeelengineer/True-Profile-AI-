import re

def preprocess_text(text):
    """Bias Reduction: Removes Names/Emails/Phone to focus on merit."""
    text = re.sub(r'\S+@\S+', '[EMAIL_REMOVED]', text)
    text = re.sub(r'\+?\d[\d -]{8,12}\d', '[PHONE_REMOVED]', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def clean_for_nlp(text):
    text = re.sub(r'\S+@\S+', '', text)
    text = re.sub(r'\+?\d[\d -]{8,12}\d', '', text)
    return text.strip()
