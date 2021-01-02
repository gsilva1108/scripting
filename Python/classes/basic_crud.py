import json


class Info(object):
    def __init__(self, json):
        data = json
        self._data = data

    def create(self, firstName=None, lastName=None, Feelings=None, Computer=None):
        if firstName == None or lastName == None or Computer == None:
            print("Not enough parameters specified. Cancelling request.")
        elif type(Feelings) != list or type(Computer) != dict:
            print(
                "Incorrect format for 'Feelings' or 'Computer' parameter. Cancelling request.")
        else:
            with open('test.json') as dt:
                data = json.load(dt)
                temp = data["UserInformation"]
                new_data = {
                    "firstName": firstName[0].upper() + firstName[1:],
                    "lastName": lastName[0].upper() + lastName[1:],
                    "userName": firstName[0].lower() + lastName.lower(),
                    "Feelings": Feelings,
                    "Computer": Computer
                }
                temp.append(new_data)
            with open('test.json', 'w') as dt:
                json.dump(data, dt, indent=4)

    def read(self, userName=None):
        if userName == None:
            print(self._data)
        else:
            users = []
            data = self._data['UserInformation']
            for user in data:
                users.append(user['userName'])
            if userName in users:
                for user in data:
                    if user['userName'] == userName:
                        print(user)
                    else:
                        pass
            else:
                print("User not found")

    def update(self, userName, key=None, value=None):
        if key == None and value == None:
            print("No parameters specified. No changes have been made.")
        elif key and value == None or key == None and value:
            print("Invalid request. Both parameters must be defined.")
        else:
            with open('test.json') as dt:
                data = json.load(dt)

            for user in data['UserInformation']:
                if user['userName'] == userName:
                    for k in user.keys():
                        if k == key:
                            user[k] = value
                        else:
                            continue
                    with open('test.json', 'w') as dt:
                        json.dump(data, dt, indent=4)

    def delete(self, userName=None):
        if userName == None:
            print("No UserName specified. Delete request cancelled.")
        else:
            with open('test.json') as dt:
                data = json.load(dt)
                users = []
                temp = data['UserInformation']
                for user in temp:
                    users.append(user['userName'])
                if userName in users:
                    for user in range(len(temp)):
                        if temp[user]["userName"] == userName:
                            temp.pop(user)
                        else:
                            continue
                else:
                    print("User not found")

            with open('test.json', 'w') as dt:
                json.dump(data, dt, indent=4)


with open('test.json', 'r') as json_file:
    data = json.load(json_file)

request = Info(data)

# Creates the user profile in test.json
# request.create("test", "user", [], {"bad": "dictionary"})

# Describes user's profile. If no user is defined, describes all user profiles
# request.read("jsmith")

# Updates the specific field requested
# request.update("gsilva", "firstName", "Gus")

# Deletes user profile from test.json
# request.delete("tuser")
