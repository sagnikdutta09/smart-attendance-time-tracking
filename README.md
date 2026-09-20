# Smart Attendance & Time Tracking System

A Salesforce-based employee attendance and time tracking application built with **Apex, Lightning Web Components (LWC), SOQL, Lightning Data Service, and Salesforce automation**.

The application provides employees with a simple interface to check in and check out, tracks daily attendance, calculates work hours, and provides attendance summaries through a Lightning dashboard.
##  Status

In Progress. Target completion date: 1st October
## Features

### Employee Attendance

- Employee check-in and check-out
- Automatic timestamp capture using Salesforce DateTime fields
- Daily attendance logging
- Work-hour calculation
- Attendance status tracking:
  - Present
  - In Progress
  - Incomplete
  - Absent

### Attendance Dashboard

- Weekly attendance percentage
- Monthly attendance percentage
- Yearly attendance percentage
- Today's attendance status
- Current check-in time
- Live current-time display while checked in
- Checkout timestamp after completing the workday
- Conditional UI based on the employee's attendance state

### Employee Management

- Employee records linked to Salesforce Users
- Department and manager relationships
- Employee attendance records automatically created when employees are created

## Technical Implementation

### Lightning Web Components

The `attendanceDashboard` LWC provides the employee-facing attendance interface.

It demonstrates:

- Imperative Apex calls
- `@wire` for Salesforce record data
- Component state and reactive UI updates
- Conditional rendering with `lwc:if`
- Apex-to-LWC data flow
- JavaScript DateTime formatting
- Promise chaining
- `setTimeout` and `setInterval`
- Component lifecycle methods

### Apex

The application uses a layered Apex structure:

```text
EmployeeTrigger
      ↓
EmployeeTriggerHandler
      ↓
EmployeeService
