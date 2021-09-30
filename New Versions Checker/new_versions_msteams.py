import pymsteams
import subprocess
import json

#***
# GLOBAL VARIABLES
#***
sections = {}
logos = { 
            'UNIFY': 'https://files.messe-muenchen.de/corporate/media/global_media/s_services/servicepartner_logos/Logo_Unify_GmbH_Co_KG_logo_cropped_600.jpg', 
            'TELEPO': 'https://res.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_170,w_170,f_auto,b_white,q_auto:eco,dpr_1/v1397185352/12d1017cd42bb7c80d253aa425866cf5.gif', 
            '3DPARTY': 'https://www.mscollab365.com/wp-content/uploads/2020/09/Third-Party-256.png'
        }
msteams_webhook_url = "<webhook-url>"
msteams_card_title = "* Detected new updates *"
msteams_card_color = "#7bad56"


#***
# FUNCTIONS
#***
def append_section(newUpdate_json):
    #here code for creating the section check if section is not created before, otherwise append to the sectiontext.
    #using section nested dictionary based on the category (split by name).
    name = line_json["name"]
    version = line_json["version"]
    category = name.split("#")[0]
    if category in sections: #check if dictionary already exists for current category
        section_text = sections[category]['section_text'] + "<br />" + name.split("#")[1] + ": " + version
        sections[category]['section_text'] = section_text
    else:
        sections[category] = {'section_name': category, 'section_text': name.split("#")[1] + ": " + version}

def send_card():
    #here code for sending the card with all sections.
    myTeamsMessage = pymsteams.connectorcard(msteams_webhook_url)
    myTeamsMessage.title(msteams_card_title)
    myTeamsMessage.text(" ") #text mandatory here, so setting empty string.
    myTeamsMessage.color(msteams_card_color) #color line on top from message.

    #Loop through sections and add to card.
    for category in sections.items():
        sectionName = category[1]['section_name']
        sectionImage = logos[sectionName]

        sectionName = pymsteams.cardsection()
        sectionName.activityTitle(category[1]['section_name'])
        sectionName.activityImage(sectionImage)
        sectionName.activityText(category[1]['section_text'])

        myTeamsMessage.addSection(sectionName)

    myTeamsMessage.send()



#***
# MAIN
#***

nvchecker = subprocess.run(['nvchecker', '-c/home/braam/nvchecker_config_BKM.toml', '--logger=json'], stdout=subprocess.PIPE)
nvchecker_response = nvchecker.stdout.decode('utf-8')

for line in nvchecker_response.split("\n"):
    if "logger_name" in line: #check first if key exists before parsing.
        line_json = json.loads(line)
        if "nvchecker.core" in line_json["logger_name"]: #we need all the .core logger names.
            if line_json["event"] == "updated": #we need only the updated releases by checking the event.
                append_section(line_json) #append to sections dictionary

#Send ms Teams message only when sections dictionary is not empty, then update the json file with nvtake command.
if len(sections) > 0:
    send_card()
    nvchecker = subprocess.run(['nvtake', '-c/home/braam/nvchecker_config_BKM.toml', '--all'], stdout=subprocess.PIPE)
