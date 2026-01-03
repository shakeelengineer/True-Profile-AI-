import fitz  # PyMuPDF
import docx
import io

def extract_text_from_pdf(file_bytes):
    text = ""
    with fitz.open(stream=file_bytes, filetype="pdf") as doc:
        for page in doc:
            text += page.get_text()
    return text

def extract_text_from_docx(file_bytes):
    doc = docx.Document(io.BytesIO(file_bytes))
    text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
    return text

def extract_resume_text(file_bytes, file_extension):
    if file_extension.lower() == ".pdf":
        return extract_text_from_pdf(file_bytes)
    elif file_extension.lower() in [".docx", ".doc"]:
        return extract_text_from_docx(file_bytes)
    else:
        raise ValueError(f"Unsupported file format: {file_extension}")
