#!/usr/bin/env bash
echo "Enter your APIC IP Address: "
read apic_ip
echo "Enter your APIC Username: "
read apic_username
echo "Enter your APIC Password: "
read -s apic_password

if [ $(uname -m) == "x86_64" ]
    then
        for app in chive_agent chive_app chive_web
        do
            if docker ps | awk -v app="app" 'NR>1{  ($(NF) == app )  }';
            then docker stop "$app" && docker rm -f "$app" && docker rmi 3pings/"$app":i386
            else echo "Nothing to remove!"
            fi
        done

        docker run --name chive_app \
            -dp 5000:5000 3pings/chive_app:i386

        docker run --name chive_agent --link chive_app:app \
            -de APIC_IP=$apic_ip \
            -e APIC_USERNAME=$apic_username \
            -e APIC_PASSWORD=$apic_password \
            3pings/chive_agent:i386

        docker run --name chive_web --link chive_app:app \
            -dp 8080:8080 3pings/chive_web:i386
    else

        for app in chive_agent chive_app chive_web
        do
            if docker ps | awk -v app="app" 'NR>1{  ($(NF) == app )  }';
            then docker stop "$app" && docker rm -f "$app" && docker rmi 3pings/"$app":arm
            else echo "Nothing to remove!"
            fi
        done

        docker run --name chive_app \
            -dp 5000:5000 3pings/chive_app:arm

        docker run --name chive_agent --link chive_app:app \
            -de APIC_IP=$apic_ip \
            -e APIC_USERNAME=$apic_username \
            -e APIC_PASSWORD=$apic_password \
            3pings/chive_agent:arm

        docker run --name chive_web --link chive_app:app \
            -dp 8080:8080 3pings/chive_web:arm
    exit 1
fi
