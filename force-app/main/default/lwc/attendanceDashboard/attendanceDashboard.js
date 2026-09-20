import { LightningElement, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import USER_Id from '@salesforce/user/Id'; //collecting present logged in user id
import USER_PROFILE from '@salesforce/schema/User.Profile.Name'; //aligning the user profile name data
import USER_NAME from '@salesforce/schema/User.Name';
import getCurrentEmployee from '@salesforce/apex/attendanceController.getCurrentEmployee';
import getCurrentEmployeeAttendance from '@salesforce/apex/attendanceController.getCurrentEmployeeAttendance';
import checkIn from '@salesforce/apex/attendanceController.checkIn';
import checkOut from '@salesforce/apex/attendanceController.checkOut';
import getTodaysLog from '@salesforce/apex/attendanceController.getTodaysLog';
import doesLogExist from '@salesforce/apex/attendanceController.doesLogExist';
import hasUserCheckedOut from '@salesforce/apex/attendanceController.hasUserCheckedOut';

export default class AttendanceDashboard extends LightningElement {
    showDialog = false;
    showDashboard = false;
    showCheckout = false;
    showCheckoutBox=false;
    userCheckIn=false;
    userProfile;
    userName;
    checkinTime=null;
    checkinTimeStamp=null;
    isAdmin=false;
    currentEmployee;
    currentEmployeeAttendance;
    countdown=null;
    currentTime=null;
    targetTime=null;
    checkOutTime=null;

    startClock(){
        this.currentTime = new Date().toLocaleTimeString([],{
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });
        this.clockInterval = setInterval(()=>{
            this.currentTime = new Date().toLocaleTimeString([],{
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });
        },6000);
    }
    connectedCallback(){
        this.startClock();
        getCurrentEmployee({userId:USER_Id}) //current logged in user's employee
        .then(result=>{
            this.currentEmployee=result;
            getCurrentEmployeeAttendance({employeeId: result.Id}) //current logged in user's employee's attendance
            .then(attendance=>{
                this.currentEmployeeAttendance = attendance;
                this.showDashboard=true;
            })
            .catch(error=>{
                console.log(error);
            });
        }).catch(error=>{
            console.log(error);
        })
        
        setTimeout(()=>{
            doesLogExist({userId: USER_Id})
            .then((result)=>{
                if(result){
                    return hasUserCheckedOut({userId: USER_Id})
                }else{
                    this.showDialog=true;
                    return null;
                }
            })
            .then((result)=>{
                    if(result!=null){
                        this.userCheckIn = !result;
                        this.showCheckout = result;
                        this.loadTodaysLog();
                    }
            }).catch(error=>{
                console.log(error);
            })
        }, 3000)
    }

    disconnectedCallback(){
        clearInterval(this.clockInterval);
    }
    @wire(getRecord,{
        recordId:USER_Id,
        fields:[USER_PROFILE, USER_NAME]
    })userInfo(result){
        this.userName = getFieldValue(result.data, USER_NAME);
        this.userProfile = getFieldValue(result.data, USER_PROFILE);
        this.isAdmin = this.userProfile === 'System Administrator';
    }

    handleClose(){
        this.showDialog=false;
    }

    getAttendanceClass(value){
    if (value > 90) {
        return 'attendance-good';
    }
    if (value > 50) {
        return 'attendance-warning';
    }
    return 'attendance-poor';
    }

    get weeklyAttendanceClass(){
        return this.getAttendanceClass(this.currentEmployeeAttendance.Weekly_Attendance__c);
    }
    get monthlyAttendanceClass(){
        return this.getAttendanceClass(this.currentEmployeeAttendance.Monthly_Attendance__c);
    }
    get yearlyAttendanceClass(){
        return this.getAttendanceClass(this.currentEmployeeAttendance.Yearly_Attendance__c);
    }

    handleCheckIn(){
        checkIn({userId:USER_Id})
        .then(()=>{
            this.showDialog=false;
            this.userCheckIn=true;
            this.loadTodaysLog();
        }).catch(error=>{
            console.log(error); 
        })
    }

    handleCheckOut(){
    checkOut({userId:USER_Id})
        .then((result)=>{
            console.log('APEX RETURNED:', result);

            if(result != null){
                this.checkOutTime = new Date(result).toLocaleTimeString([],{
                    hour: 'numeric',
                    minute: '2-digit',
                    hour12: true
                });
                this.showCheckout = true;
                this.userCheckIn = false;
                this.showCheckoutBox=true;
            }
        })
        .catch(error=>{
            console.log(error);
        });
}

    closeCheckout(){
        this.showCheckoutBox=false;
    }

    loadTodaysLog(){
        getTodaysLog({userId:USER_Id})
        .then((result)=>{
            this.checkinTimeStamp = new Date(result.Check_In__c);
            this.checkinTime=new Date(result.Check_In__c).toLocaleTimeString([],{
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });
        }).catch((error)=>{
            console.log(error);
        })
    }



    // calculateCountdown(){
    //     targetTime = new Date(
    //         this.checkinTimeStamp.getTime()+(9*60*60*1000));
    // }
}