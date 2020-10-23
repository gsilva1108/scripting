list = ['a1', 'b2', 'c3']
types = ['a2.large', 'b2.medium', 'c4.small']

for l in list:
    if any(l in s for s in types):
        print("good")
    else:
        print("no good")
