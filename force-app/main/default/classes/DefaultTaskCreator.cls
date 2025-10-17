public with sharing class DefaultTaskCreator {
  public class Inputs { @InvocableVariable(required=true) public String Subject; @InvocableVariable public Id WhatId; @InvocableVariable public String Status; }
  @InvocableMethod(label='Create Task') public static List<Id> createTask(List<Inputs> inputs){
    List<Id> out=new List<Id>(); for(Inputs i:inputs){ Task t=new Task(Subject=i.Subject, Status=(i.Status==null?'Not Started':i.Status)); if(i.WhatId!=null) t.WhatId=i.WhatId; insert t; out.add(t.Id);} return out;
  }
}
