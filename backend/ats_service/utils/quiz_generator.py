"""
Quiz Question Generator
This module generates skill-specific quiz questions for various technical domains.
"""

import random
from typing import List, Dict, Any
import os

class QuizGenerator:
    """Generate quiz questions for skill verification"""
    
    def __init__(self):
        """Initialize the quiz generator"""
        self.api_key = os.getenv('OPENAI_API_KEY', '')
        
    def generate_questions(self, skill: str, num_questions: int = 10) -> List[Dict[str, Any]]:
        """
        Generate questions for the requested skill
        """
        try:
            skill_map = {
                'python': self._get_python_questions,
                'javascript': self._get_javascript_questions,
                'js': self._get_javascript_questions,
                'java': self._get_java_questions,
                'flutter': self._get_flutter_questions,
                'react': self._get_react_questions,
                'node.js': self._get_nodejs_questions,
                'nodejs': self._get_nodejs_questions,
                'data science': self._get_datascience_questions,
                'machine learning': self._get_ml_questions,
                'artificial intelligence': self._get_ai_questions,
                'ai': self._get_ai_questions,
                'sql': self._get_sql_questions,
                'aws': self._get_aws_questions,
                'data structures': self._get_ds_questions,
                'algorithms': self._get_algo_questions,
                'operating systems': self._get_os_questions,
                'computer networks': self._get_networks_questions,
                'cybersecurity': self._get_cyber_questions,
                'c++': self._get_cpp_questions,
                'cpp': self._get_cpp_questions,
                'c#': self._get_csharp_questions,
                'php': self._get_php_questions,
                'go': self._get_go_questions,
                'rust': self._get_rust_questions,
                'devops': self._get_devops_questions,
                'software testing': self._get_testing_questions,
            }
            
            skill_lower = skill.lower().strip()
            
            if skill_lower in skill_map:
                questions = skill_map[skill_lower]()
            else:
                questions = self._get_generic_questions(skill)
            
            # CRITICAL: Shuffle the pool before picking
            random.shuffle(questions)
            
            # If we have less than num_questions, fill with generic ones to ensure pool size
            if len(questions) < num_questions:
                additional = self._get_generic_questions(skill)
                random.shuffle(additional)
                questions.extend(additional)
                
            # Select unique questions for this session
            return questions[:num_questions]
            
        except Exception as e:
            print(f"Error generating questions for {skill}: {e}")
            return self._get_generic_questions(skill)[:num_questions]

    def _get_python_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'What is the output of: print(type([]) == list)?', 'options': ['True', 'False', 'Error', 'None'], 'answer': 0, 'skill': 'Python'},
            {'question': 'Which keyword is used to define a function?', 'options': ['function', 'def', 'func', 'define'], 'answer': 1, 'skill': 'Python'},
            {'question': 'How do you create a dictionary?', 'options': ['[]', '()', '{}', '<>'], 'answer': 2, 'skill': 'Python'},
            {'question': 'Which keyword handles exceptions?', 'options': ['catch', 'try', 'except', 'finally'], 'answer': 2, 'skill': 'Python'},
            {'question': 'What does "self" represent in classes?', 'options': ['Class itself', 'Instance of class', 'A static var', 'Global scope'], 'answer': 1, 'skill': 'Python'},
            {'question': 'Which method is the constructor?', 'options': ['__init__', '__new__', '__start__', '__main__'], 'answer': 0, 'skill': 'Python'},
            {'question': 'Output of: bool([])?', 'options': ['True', 'False', 'Error', 'None'], 'answer': 1, 'skill': 'Python'},
            {'question': 'Which is NOT a valid data type?', 'options': ['list', 'tuple', 'set', 'array'], 'answer': 3, 'skill': 'Python'},
            {'question': 'What is floor division operator?', 'options': ['/', '//', '%', '**'], 'answer': 1, 'skill': 'Python'},
            {'question': 'What is a lambda function?', 'options': ['Named function', 'Anonymous function', 'Static method', 'Class method'], 'answer': 1, 'skill': 'Python'},
            {'question': 'How to import a module?', 'options': ['include', 'require', 'import', 'using'], 'answer': 2, 'skill': 'Python'},
            {'question': 'Which list method removes an element?', 'options': ['delete()', 'remove()', 'erase()', 'discard()'], 'answer': 1, 'skill': 'Python'},
            {'question': 'What is the correct way to start a loop?', 'options': ['for x in y:', 'for(x;y;z)', 'while x < y then', 'loop x:'], 'answer': 0, 'skill': 'Python'},
            {'question': 'What does range(5) produce?', 'options': ['[1,2,3,4,5]', '[0,1,2,3,4]', '[0,1,2,3,4,5]', 'Error'], 'answer': 1, 'skill': 'Python'},
            {'question': 'Which PEP defines the style guide?', 'options': ['PEP 20', 'PEP 440', 'PEP 8', 'PEP 1'], 'answer': 2, 'skill': 'Python'},
            {'question': 'What is a decorator in Python?', 'options': ['A function wrapper', 'A UI element', 'A class type', 'A list method'], 'answer': 0, 'skill': 'Python'},
            {'question': 'How to check if key exists in dict?', 'options': ['has_key()', 'in keyword', 'exists()', 'find()'], 'answer': 1, 'skill': 'Python'},
            {'question': 'What is list comprehension?', 'options': ['List reading', 'Concise way to create lists', 'List sorting', 'List deletion'], 'answer': 1, 'skill': 'Python'},
        ]

    def _get_java_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Correct main method signature?', 'options': ['public void main()', 'public static void main(String[] args)', 'static void main()', 'void main()'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Keyword for class inheritance?', 'options': ['inherits', 'extends', 'implements', 'using'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Compilation result of Java code?', 'options': ['.exe', '.class', '.java', '.bin'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Used to handle exceptions?', 'options': ['if-else', 'try-catch', 'throw-only', 'error-log'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Collection with no duplicates?', 'options': ['List', 'Set', 'Map', 'Stack'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Final keyword on variable?', 'options': ['Constant', 'Static', 'Global', 'Deleted'], 'answer': 0, 'skill': 'Java'},
            {'question': 'Root class of Java hierarchy?', 'options': ['Object', 'System', 'Base', 'Root'], 'answer': 0, 'skill': 'Java'},
            {'question': 'Keyword for interface usage?', 'options': ['extends', 'implements', 'uses', 'applies'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Size of int type?', 'options': ['16-bit', '32-bit', '64-bit', '8-bit'], 'answer': 1, 'skill': 'Java'},
            {'question': 'JVM stands for?', 'options': ['Java Visual Model', 'Java Virtual Machine', 'Joint Variable Map', 'None'], 'answer': 1, 'skill': 'Java'},
            {'question': 'Access modifier for same package?', 'options': ['public', 'private', 'protected', 'default'], 'answer': 3, 'skill': 'Java'},
            {'question': 'What is a constructor?', 'options': ['Frees memory', 'Initializes an object', 'Creates a thread', 'Defines a class'], 'answer': 1, 'skill': 'Java'},
        ]

    def _get_flutter_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Language used by Flutter?', 'options': ['Java', 'Swift', 'Dart', 'Kotlin'], 'answer': 2, 'skill': 'Flutter'},
            {'question': 'Base units of Flutter UI?', 'options': ['Components', 'Widgets', 'Elements', 'Views'], 'answer': 1, 'skill': 'Flutter'},
            {'question': 'What is a StatelessWidget?', 'options': ['Dynamic UI', 'UI that never changes state', 'Background task', 'Data model'], 'answer': 1, 'skill': 'Flutter'},
            {'question': 'Method to update StatefulWidget?', 'options': ['build()', 'update()', 'setState()', 'refresh()'], 'answer': 2, 'skill': 'Flutter'},
            {'question': 'What is Pubspec.yaml?', 'options': ['Main code', 'Project config and assets', 'Database file', 'Log file'], 'answer': 1, 'skill': 'Flutter'},
            {'question': 'Command to run Flutter app?', 'options': ['flutter start', 'flutter run', 'flutter play', 'flutter build'], 'answer': 1, 'skill': 'Flutter'},
            {'question': 'Hot Reload benefit?', 'options': ['App restart', 'Quick code updates without losing state', 'Build faster', 'Clear cache'], 'answer': 1, 'skill': 'Flutter'},
            {'question': 'What is an "Expanded" widget?', 'options': ['Adds padding', 'Fills available space', 'Creates a button', 'Sets color'], 'answer': 1, 'skill': 'Flutter'},
        ]

    def _get_react_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'What is JSX?', 'options': ['JavaScript XML', 'JSON extension', 'CSS framework', 'Logic tool'], 'answer': 0, 'skill': 'React'},
            {'question': 'Hook for state management?', 'options': ['useEffect', 'useState', 'useContext', 'useReducer'], 'answer': 1, 'skill': 'React'},
            {'question': 'What is Virtual DOM?', 'options': ['Real browser DOM', 'Memory representation of UI', 'Visual editor', 'Database'], 'answer': 1, 'skill': 'React'},
            {'question': 'How to pass data to children?', 'options': ['Context', 'Props', 'State', 'Global'], 'answer': 1, 'skill': 'React'},
            {'question': 'Purpose of useEffect hook?', 'options': ['State updates', 'Side effects', 'Rendering', 'Routing'], 'answer': 1, 'skill': 'React'},
            {'question': 'What is a "Higher-Order Component"?', 'options': ['A large component', 'Function that returns a component', 'First component built', 'Layout helper'], 'answer': 1, 'skill': 'React'},
        ]

    def _get_nodejs_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'What is Node.js?', 'options': ['JS Framework', 'JS Runtime Environment', 'Web browser', 'Compiler'], 'answer': 1, 'skill': 'Node.js'},
            {'question': 'Engine used by Node.js?', 'options': ['SpiderMonkey', 'V8', 'Chakra', 'Rhino'], 'answer': 1, 'skill': 'Node.js'},
            {'question': 'Module for web servers?', 'options': ['fs', 'http', 'path', 'os'], 'answer': 1, 'skill': 'Node.js'},
            {'question': 'What is NPM?', 'options': ['Node Process Manager', 'Node Package Manager', 'Network Program Module', 'None'], 'answer': 1, 'skill': 'Node.js'},
            {'question': 'Purpose of "package.json"?', 'options': ['Logic', 'Dependencies and metadata', 'Log file', 'Style'], 'answer': 1, 'skill': 'Node.js'},
            {'question': 'Node.js is...?', 'options': ['Multi-threaded', 'Single-threaded event loop', 'Synchronous', 'Browser-based'], 'answer': 1, 'skill': 'Node.js'},
        ]

    def _get_datascience_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Library for data manipulation?', 'options': ['Matplotlib', 'Pandas', 'Requests', 'Pytest'], 'answer': 1, 'skill': 'Data Science'},
            {'question': 'Common tool for interactive data work?', 'options': ['Notepad', 'Jupyter Notebook', 'Chrome', 'Spotify'], 'answer': 1, 'skill': 'Data Science'},
            {'question': 'Central limit theorem relates to?', 'options': ['Logic', 'Probability distributions', 'Sorting', 'Networking'], 'answer': 1, 'skill': 'Data Science'},
            {'question': 'What is a Histogram?', 'options': ['Line chart', 'Frequency distribution graph', 'List', 'Map'], 'answer': 1, 'skill': 'Data Science'},
            {'question': 'Data Science workflow starts with?', 'options': ['Model build', 'Question/Data collection', 'Deployment', 'Testing'], 'answer': 1, 'skill': 'Data Science'},
        ]

    def _get_ml_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Supervised learning needs...?', 'options': ['Big data', 'Labeled data', 'No data', 'Random data'], 'answer': 1, 'skill': 'Machine Learning'},
            {'question': 'Algorithm for classification?', 'options': ['Linear Regression', 'Logistic Regression', 'Heapsort', 'Prim'], 'answer': 1, 'skill': 'Machine Learning'},
            {'question': 'Unsupervised learning goal?', 'options': ['Predicting Y', 'Finding hidden patterns/clusters', 'Data cleaning', 'UI design'], 'answer': 1, 'skill': 'Machine Learning'},
            {'question': 'Overfitting means?', 'options': ['Model is too simple', 'Model fits training noise too well', 'Model is too fast', 'None'], 'answer': 1, 'skill': 'Machine Learning'},
            {'question': 'Regularization helps to?', 'options': ['Speed up training', 'Prevent overfitting', 'Add data', 'Visualize'], 'answer': 1, 'skill': 'Machine Learning'},
        ]

    def _get_ai_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'AI category that mimics human brain?', 'options': ['Logic Gates', 'Neural Networks', 'Linear search', 'Manual entry'], 'answer': 1, 'skill': 'AI'},
            {'question': 'Test for machine intelligence?', 'options': ['IQ Test', 'Turing Test', 'Unit Test', 'Speed Test'], 'answer': 1, 'skill': 'AI'},
            {'question': 'NLP stands for?', 'options': ['Node Logic Process', 'Natural Language Processing', 'National Logic Program', 'Network Link Protocol'], 'answer': 1, 'skill': 'AI'},
            {'question': 'Heuristic search is used in...?', 'options': ['Simple loops', 'Pathfinding/Games', 'Data entry', 'Hard drive formatting'], 'answer': 1, 'skill': 'AI'},
            {'question': 'What are Expert Systems?', 'options': ['Skilled humans', 'AI replicating human expert knowledge', 'Fast computers', 'Database tools'], 'answer': 1, 'skill': 'AI'},
        ]

    def _get_aws_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Service for EC2 instances?', 'options': ['S3', 'RDS', 'EC2', 'Lambda'], 'answer': 2, 'skill': 'AWS'},
            {'question': 'Service for scalable object storage?', 'options': ['EBS', 'S3', 'RDS', 'VPC'], 'answer': 1, 'skill': 'AWS'},
            {'question': 'Managed Relational Database Service?', 'options': ['DynamoDB', 'RDS', 'Redshift', 'Athena'], 'answer': 1, 'skill': 'AWS'},
            {'question': 'What is IAM?', 'options': ['Internet Access Manager', 'Identity and Access Management', 'Internal Audit Map', 'None'], 'answer': 1, 'skill': 'AWS'},
            {'question': 'Serverless compute service?', 'options': ['EC2', 'Lambda', 'Fargate', 'Lightsail'], 'answer': 1, 'skill': 'AWS'},
        ]

    def _get_ds_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Search time in Hash Map (Average)?', 'options': ['O(1)', 'O(n)', 'O(log n)', 'O(n^2)'], 'answer': 0, 'skill': 'Data Structures'},
            {'question': 'FIFO structure?', 'options': ['Stack', 'Queue', 'Array', 'Tree'], 'answer': 1, 'skill': 'Data Structures'},
            {'question': 'LIFO structure?', 'options': ['Stack', 'Queue', 'Array', 'Tree'], 'answer': 0, 'skill': 'Data Structures'},
            {'question': 'Time to access Array by index?', 'options': ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'], 'answer': 1, 'skill': 'Data Structures'},
            {'question': 'Not a linear data structure?', 'options': ['Linked List', 'Stack', 'Queue', 'Graph'], 'answer': 3, 'skill': 'Data Structures'},
            {'question': 'What is a leaf node?', 'options': ['Root', 'Node with children', 'Node with no children', 'Center node'], 'answer': 2, 'skill': 'Data Structures'},
            {'question': 'Insert at head of Linked List?', 'options': ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'], 'answer': 1, 'skill': 'Data Structures'},
            {'question': 'Binary Tree property?', 'options': ['Nodes have exactly 2 kids', 'Nodes have at most 2 kids', 'Nodes have min 1 kid', 'Circular'], 'answer': 1, 'skill': 'Data Structures'},
        ]

    def _get_algo_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Quick Sort average complexity?', 'options': ['O(n^2)', 'O(n log n)', 'O(log n)', 'O(n)'], 'answer': 1, 'skill': 'Algorithms'},
            {'question': 'Binary Search complexity?', 'options': ['O(n)', 'O(log n)', 'O(1)', 'O(n log n)'], 'answer': 1, 'skill': 'Algorithms'},
            {'question': 'Greedy algorithm example?', 'options': ['Mergesort', 'Dijkstra', 'Heapsort', 'Quick Sort'], 'answer': 1, 'skill': 'Algorithms'},
            {'question': 'Dynamic Programming principal?', 'options': ['Divide & Conquer', 'Recursion + Memoization', 'Brute force', 'Guess'], 'answer': 1, 'skill': 'Algorithms'},
            {'question': 'Bubble Sort worst case?', 'options': ['O(n log n)', 'O(n)', 'O(n^2)', 'O(2^n)'], 'answer': 2, 'skill': 'Algorithms'},
            {'question': 'Algorithm to find short path?', 'options': ['Prim', 'Kruskal', 'Dijkstra', 'DFS'], 'answer': 2, 'skill': 'Algorithms'},
        ]

    def _get_os_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'What is Thrashing?', 'options': ['CPU Speed', 'Excessive Paging', 'Cleanup', 'Hanging'], 'answer': 1, 'skill': 'Operating Systems'},
            {'question': 'Smallest execution unit?', 'options': ['Process', 'Thread', 'Task', 'Logic'], 'answer': 1, 'skill': 'Operating Systems'},
            {'question': 'Virtual Memory is...?', 'options': ['Cloud RAM', 'Disk space acting as RAM', 'Hardware RAM', 'ROM'], 'answer': 1, 'skill': 'Operating Systems'},
            {'question': 'Context Switching target?', 'options': ['Users', 'Processes/Threads', 'Disks', 'NICs'], 'answer': 1, 'skill': 'Operating Systems'},
            {'question': 'Deadlock condition NOT included?', 'options': ['No Preemption', 'Hold & Wait', 'Mutual Exclusion', 'Preemption'], 'answer': 3, 'skill': 'Operating Systems'},
        ]

    def _get_networks_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'OSI model layers?', 'options': ['4', '5', '7', '8'], 'answer': 2, 'skill': 'Computer Networks'},
            {'question': 'Port for HTTPS?', 'options': ['80', '443', '21', '22'], 'answer': 1, 'skill': 'Computer Networks'},
            {'question': 'IP belongs to which layer?', 'options': ['Data Link', 'Network', 'Transport', 'Application'], 'answer': 1, 'skill': 'Computer Networks'},
            {'question': 'Device that connects subnets?', 'options': ['Switch', 'Bridge', 'Router', 'Hub'], 'answer': 2, 'skill': 'Computer Networks'},
            {'question': 'Reliable transport protocol?', 'options': ['UDP', 'TCP', 'ICMP', 'DNS'], 'answer': 1, 'skill': 'Computer Networks'},
        ]

    def _get_cyber_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'CIA Triad stands for?', 'options': ['Central Int Access', 'Confidentiality Integrity Availability', 'Core Internal Audit', 'None'], 'answer': 1, 'skill': 'Cybersecurity'},
            {'question': 'SQL Injection targets?', 'options': ['Web UI', 'Database', 'Operating System', 'CPU'], 'answer': 1, 'skill': 'Cybersecurity'},
            {'question': 'Phishing medium usually is?', 'options': ['Physical mail', 'Email', 'TV', 'Radio'], 'answer': 1, 'skill': 'Cybersecurity'},
            {'question': 'Ransomware action?', 'options': ['Steals money directly', 'Encrypts files for ransom', 'Deletes OS', 'Speeds up PC'], 'answer': 1, 'skill': 'Cybersecurity'},
            {'question': 'Secure web protocol?', 'options': ['HTTP', 'HTTPS', 'FTP', 'Telnet'], 'answer': 1, 'skill': 'Cybersecurity'},
        ]

    def _get_cpp_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Who developed C++?', 'options': ['Dennis Ritchie', 'Bjarne Stroustrup', 'Gosling', 'Guido'], 'answer': 1, 'skill': 'C++'},
            {'question': 'Used for dynamic memory?', 'options': ['malloc', 'new', 'create', 'alloc'], 'answer': 1, 'skill': 'C++'},
            {'question': 'Operator for pointer members?', 'options': ['.', '->', '::', '*'], 'answer': 1, 'skill': 'C++'},
            {'question': 'Virtual function purpose?', 'options': ['Speed', 'Runtime Polymorphism', 'Memory saving', 'Security'], 'answer': 1, 'skill': 'C++'},
            {'question': 'Default access in class?', 'options': ['public', 'private', 'protected', 'package'], 'answer': 1, 'skill': 'C++'},
        ]

    def _get_csharp_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Company behind C#?', 'options': ['Apple', 'Microsoft', 'Google', 'Oracle'], 'answer': 1, 'skill': 'C#'},
            {'question': 'Extension for C# scripts?', 'options': ['.ch', '.cs', '.class', '.py'], 'answer': 1, 'skill': 'C#'},
            {'question': 'Used to manage memory?', 'options': ['Manual delete', 'Garbage Collector', 'RAII', 'Malloc'], 'answer': 1, 'skill': 'C#'},
            {'question': 'Keyword for inheritance?', 'options': ['extends', ':', 'inherits', 'using'], 'answer': 1, 'skill': 'C#'},
            {'question': 'CLR stands for?', 'options': ['Common Language Runtime', 'Code Link Repository', 'Class Library Runner', 'None'], 'answer': 0, 'skill': 'C#'},
        ]

    def _get_rust_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Rust key differentiator?', 'options': ['Speed', 'Memory safety without GC', 'Syntax', 'UI'], 'answer': 1, 'skill': 'Rust'},
            {'question': 'Package manager?', 'options': ['npm', 'cargo', 'pip', 'gem'], 'answer': 1, 'skill': 'Rust'},
            {'question': 'Borrow Checker purpose?', 'options': ['Check grammar', 'Enforce ownership/references', 'Speed up code', 'Sorting'], 'answer': 1, 'skill': 'Rust'},
        ]

    def _get_go_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Who created Go?', 'options': ['Microsoft', 'Google', 'Facebook', 'IBM'], 'answer': 1, 'skill': 'Go'},
            {'question': 'How to handle concurrency?', 'options': ['Threads', 'Goroutines & Channels', 'Async/Await', 'Callbacks'], 'answer': 1, 'skill': 'Go'},
            {'question': 'Keyword to start goroutine?', 'options': ['start', 'run', 'go', 'async'], 'answer': 2, 'skill': 'Go'},
        ]

    def _get_php_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'PHP is a...?', 'options': ['Frontend language', 'Server-side language', 'Database', 'OS'], 'answer': 1, 'skill': 'PHP'},
            {'question': 'Variables start with?', 'options': ['#', '$', '@', '&'], 'answer': 1, 'skill': 'PHP'},
            {'question': 'Correct script tag?', 'options': ['<script>', '<?php', '<php>', '<%'], 'answer': 1, 'skill': 'PHP'},
        ]

    def _get_devops_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'What is CI?', 'options': ['Code Internal', 'Continuous Integration', 'Computing Interface', 'None'], 'answer': 1, 'skill': 'DevOps'},
            {'question': 'Container engine popular?', 'options': ['Xen', 'Docker', 'VirtualBox', 'Wine'], 'answer': 1, 'skill': 'DevOps'},
            {'question': 'Tool for CI/CD?', 'options': ['Excel', 'Jenkins', 'Word', 'Chrome'], 'answer': 1, 'skill': 'DevOps'},
        ]

    def _get_testing_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Unit test scope?', 'options': ['Whole system', 'Single component/function', 'Network', 'User UI'], 'answer': 1, 'skill': 'Software Testing'},
            {'question': 'TDD stands for?', 'options': ['Technical Dev Design', 'Test Driven Development', 'Type Data Design', 'None'], 'answer': 1, 'skill': 'Software Testing'},
            {'question': 'Black box means?', 'options': ['Test code directly', 'Test without code knowledge', 'Test hardware', 'Test speed'], 'answer': 1, 'skill': 'Software Testing'},
        ]

    def _get_javascript_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Output of "typeof null"?', 'options': ['null', 'undefined', 'object', 'boolean'], 'answer': 2, 'skill': 'JavaScript'},
            {'question': 'Strict equality operator?', 'options': ['==', '===', '=', '!='], 'answer': 1, 'skill': 'JavaScript'},
            {'question': 'Parse JSON script?', 'options': ['JSON.parse()', 'JSON.stringify()', 'JSON.into()', 'JSON.object()'], 'answer': 0, 'skill': 'JavaScript'},
            {'question': 'Keyword for ES6 variables?', 'options': ['var', 'let', 'val', 'set'], 'answer': 1, 'skill': 'JavaScript'},
            {'question': 'What is DOM?', 'options': ['Document Object Model', 'Data Object Manager', 'Digital Output', 'None'], 'answer': 0, 'skill': 'JavaScript'},
        ]

    def _get_sql_questions(self) -> List[Dict[str, Any]]:
        return [
            {'question': 'Retrieve data command?', 'options': ['GET', 'SELECT', 'EXTRACT', 'QUERY'], 'answer': 1, 'skill': 'SQL'},
            {'question': 'Command to remove table?', 'options': ['DELETE', 'REMOVE', 'DROP', 'TRUNCATE'], 'answer': 2, 'skill': 'SQL'},
            {'question': 'Unique ID constraint?', 'options': ['Foreign Key', 'Primary Key', 'Index', 'Unique'], 'answer': 1, 'skill': 'SQL'},
            {'question': 'Modify data command?', 'options': ['MODIFY', 'CHANGE', 'UPDATE', 'ALTER'], 'answer': 2, 'skill': 'SQL'},
        ]

    def _get_generic_questions(self, skill: str) -> List[Dict[str, Any]]:
        return [
            {'question': f'What is the fundamental goal of {skill}?', 'options': ['Problem solving', 'Data entry', 'Typing speed', 'Entertainment'], 'answer': 0, 'skill': skill},
            {'question': f'Which is a core concept in {skill}?', 'options': ['Logic', 'Art', 'Sports', 'None'], 'answer': 0, 'skill': skill},
            {'question': f'Correct approach to {skill}?', 'options': ['Structured logic', 'Random choice', 'Guesswork', 'Speed only'], 'answer': 0, 'skill': skill},
            {'question': f'Best way to learn {skill}?', 'options': ['Reading only', 'Practice & Projects', 'Videos only', 'Watching others'], 'answer': 1, 'skill': skill},
            {'question': f'Used in {skill} for organization?', 'options': ['Folders', 'Algorithms', 'Notes', 'Themes'], 'answer': 1, 'skill': skill},
            {'question': f'What is documentation in {skill}?', 'options': ['User guide', 'Artist notes', 'Code comments', 'Legal papers'], 'answer': 2, 'skill': skill},
            {'question': f'Initial step in {skill} project?', 'options': ['Coding', 'Planning', 'Testing', 'Deployment'], 'answer': 1, 'skill': skill},
            {'question': f'Important factor for {skill} scalability?', 'options': ['Colors', 'Design patterns', 'Screen size', 'Keyboard'], 'answer': 1, 'skill': skill},
            {'question': f'What is optimization in {skill}?', 'options': ['Making it pretty', 'Improving performance', 'Adding features', 'Reducing code'], 'answer': 1, 'skill': skill},
            {'question': f'Version control in {skill} is for?', 'options': ['Privacy', 'Tracking changes', 'Speed', 'Formatting'], 'answer': 1, 'skill': skill},
        ]

def generate_quiz(skill: str, num_questions: int = 10) -> Dict[str, Any]:
    """Main function to generate quiz questions"""
    generator = QuizGenerator()
    questions = generator.generate_questions(skill, num_questions)
    
    return {
        'skill': skill,
        'total_questions': len(questions),
        'passing_score': 80,
        'questions': questions
    }
