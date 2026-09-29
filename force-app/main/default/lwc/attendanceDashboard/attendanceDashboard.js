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
import getCurrentEmployeeAttendanceLog from '@salesforce/apex/attendanceController.getCurrentEmployeeAttendanceLog';
import getWeeklyAttendance from '@salesforce/apex/attendanceController.getWeeklyAttendance';
import getMonthlyAttendance from '@salesforce/apex/attendanceController.getMonthlyAttendance';
import getYearlyAttendance from '@salesforce/apex/attendanceController.getYearlyAttendance';

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
    attendanceLogs=null;
    weeklyAttendancePercentage=null;
    monthlyAttendancePercentage=null;
    yearlyAttendancePercentage=null;

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
        console.log('Dashboard loaded');
        this.startClock();
        getCurrentEmployee({userId:USER_Id}) //current logged in user's employee
        .then(result=>{
            this.currentEmployee=result;
            getCurrentEmployeeAttendance({employeeId: result.Id}) //current logged in user's employee's attendance
            .then(attendance=>{
                this.currentEmployeeAttendance = attendance;
                this.showDashboard=true;
                getCurrentEmployeeAttendanceLog().
                then(result=>{
                    this.attendanceLogs=result
                }).catch(error=>{
                    console.log(error);
                })
            })
            .catch(error=>{
                console.log(error);
            });
        }).catch(error=>{
            console.log(error);;
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

@wire(getWeeklyAttendance)
wiredWeeklyAttendance(result) {
    if (result.data !== undefined) {
        this.weeklyAttendancePercentage = result.data;
    }

    if (result.error) {
        console.log(result.error);
    }
}

@wire(getMonthlyAttendance)
wiredMonthlyAttendance(result){
    if(result.data!=undefined){
        this.monthlyAttendancePercentage = result.data;
    }
    if(result.error){
        console.log(result.error);
    }
}

@wire(getYearlyAttendance)
wiredYearlyAttendance(result){
    if(result.data!=undefined){
        this.yearlyAttendancePercentage = result.data;
    }
    if(result.error){
        console.log(result.error);
    }
}

    handleClose(){
        this.showDialog=false;
    }

    getAttendanceClass(value){
    if (value >= 90) {
        return 'attendance-good';
    }
    if (value >= 50) {
        return 'attendance-warning';
    }
    return 'attendance-poor';
    }

    get weeklyAttendanceClass(){
        return this.getAttendanceClass(this.weeklyAttendancePercentage);
    }
    get monthlyAttendanceClass(){
        return this.getAttendanceClass(this.monthlyAttendancePercentage);
    }
    get yearlyAttendanceClass(){
        return this.getAttendanceClass(this.yearlyAttendancePercentage);
    }

    handleCheckIn(){
        checkIn()
        .then(()=>{
            console.log(USER_Id);
            this.showDialog=false;
            this.userCheckIn=true;
            this.loadTodaysLog();
        }).catch(error=>{
            console.log(error); 
        })
    }

handleCheckOut(){
    checkOut()
        .then((result)=>{
            console.log('CHECKOUT RESULT:', result);

            if(result != null){
                this.checkOutTime = new Date(result).toLocaleTimeString([],{
                    hour: 'numeric',
                    minute: '2-digit',
                    hour12: true
                });

                console.log('CHECKOUT DISPLAY:', this.checkOutTime);

                this.showCheckout = true;
                this.userCheckIn = false;
                this.showCheckoutBox = true;
            }
        })
        .catch(error=>{
            console.log('CHECKOUT ERROR:', error);
        });
}
    closeCheckout(){
        this.showCheckoutBox=false;
        window.location.reload();
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
        if(result.Check_Out__c){
            this.checkOutTime=new Date(result.Check_Out__c).toLocaleTimeString([],{
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });  
            }
        }).catch((error)=>{
            console.log(error);
        })
    }
}