import sys

def query_yes_no(question):
    yes = {'yes','y', 'ye', ''}
    no = {'no','n'}

    sys.stdout.write(question + " [y/n] ")
    choice = input().lower()
    if choice in yes:
        return True
    elif choice in no:
        return False
    else:
        sys.stdout.write("Please respond with 'yes' or 'no'")