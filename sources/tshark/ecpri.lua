-- ecpri.lua
-- version 1.14
-- written by Bob Chalmers
-- 
-- Wireshark dissector routine for ecpri protocol

ecpri_proto = Proto("ecpri","Enhanced Common Public Radio Interface")

-- eCPRI lengths  
ECPRI_HEADER_LENGTH = 4
ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH     = 4
ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH       = 4
ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH       = 8
ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH       = 12
ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH       = 20
ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH       = 3
ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH       = 4
ECPRI_MSG_TYPE_7_ELEMENT_SIZE             = 8    

-- Action Types in Message Type 5: One-way Delay Measurement
ECPRI_MSG_TYPE_5_REQ                    = 0x00
ECPRI_MSG_TYPE_5_REQ_FOLLOWUP           = 0x01
ECPRI_MSG_TYPE_5_RESPONSE               = 0x02
ECPRI_MSG_TYPE_5_REMOTE_REQ             = 0x03
ECPRI_MSG_TYPE_5_REMOTE_REQ_FOLLOWUP    = 0x04
ECPRI_MSG_TYPE_5_FOLLOWUP               = 0x05
ECPRI_MSG_TYPE_5_RESERVED_MIN           = 0x06
ECPRI_MSG_TYPE_5_RESERVED_MAX           = 0xFF

-- Event Types in Message Type 7: Event Indication
ECPRI_MSG_TYPE_7_FAULT_INDICATION       = 0x00
ECPRI_MSG_TYPE_7_FAULT_INDICATION_ACK   = 0x01
ECPRI_MSG_TYPE_7_NOTIF_INDICATION       = 0x02
ECPRI_MSG_TYPE_7_SYNC_REQUEST           = 0x03
ECPRI_MSG_TYPE_7_SYNC_ACK               = 0x04
ECPRI_MSG_TYPE_7_SYNC_END_INDICATION    = 0x05
ECPRI_MSG_TYPE_7_RESERVED_MIN           = 0x06
ECPRI_MSG_TYPE_7_RESERVED_MAX           = 0xFF

--- Fault/Notification Ranges in Message Type 7: Event Indication
ECPRI_MSG_TYPE_7_FAULTS_MIN             = 0x000
ECPRI_MSG_TYPE_7_FAULTS_MAX             = 0x3FF
ECPRI_MSG_TYPE_7_NOTIF_MIN              = 0x400
ECPRI_MSG_TYPE_7_NOTIF_MAX              = 0x7FF
ECPRI_MSG_TYPE_7_VENDOR_MIN             = 0x800
ECPRI_MSG_TYPE_7_VENDOR_MAX             = 0xFFF 

-- Field Encoding of Message Types 
message_types = {{0,"IQ Data"}, {1,"Bit Sequence"}, {2,"Real-Time Control Data"}, {3,"Generic Data Transfer"}, {4,"Remote Memory Access"}, {5,"One-Way Delay Measurement"}, {6,"Remote Reset"}, {7,"Event Indication"},
                 -- 8-63 Reserved
                 {8,"Reserved"}, {63,"Reserved"}, 
                 -- 64-255 Vendor Specific
                 {64,"Vendor Specific"}, {255,"Vendor Specific"}}

local function getMessageTypeString(messageType, messageTypeStrings)       
    for i,v in ipairs(messageTypeStrings) do 
        if v[1] >= messageType then
            return v[2]
        end
    end
end

-- eCPRI Common Header
ecpri_proto.fields.header = ProtoField.uint32("ecpri.header", "eCPRI Common Header", base.HEX)
ecpri_proto.fields.revision = ProtoField.uint8("ecpri.revision", "Protocol Revision", base.DEC, nil, 0xF0)
ecpri_proto.fields.reserved = ProtoField.uint8("ecpri.reserved", "Reserved", base.DEC, nil, 0x0E)
ecpri_proto.fields.cbit = ProtoField.uint8("ecpri.cbit", "C-Bit", base.DEC, nil, 0x01)
ecpri_proto.fields.message_type = ProtoField.uint8("ecpri.message_type", "Message Type", base.HEX)
ecpri_proto.fields.payload_size = ProtoField.uint16("ecpri.payload_size", "Payload Size", base.DEC)
-- eCPRI Payload
ecpri_proto.fields.payload = ProtoField.bytes("epri.payload", "Payload")
-- Message Type 0 and 1: IQ Data and Bit Sequence
ecpri_proto.fields.pc_id = ProtoField.uint16("epri.pc_id", "PC_ID", base.HEX)
-- Message Type 0, 1 and 2: IQ Data, Bit Sequence and Real-Time Control Data
ecpri_proto.fields.seq_id = ProtoField.uint16("epri.seq_id", "SEQ_ID", base.HEX)
-- Message Type 2: Real-Time Control Data
ecpri_proto.fields.rtc_id = ProtoField.uint16("epri.rtc_id", "RTC_ID", base.HEX)
-- Message Type 3: Generic Data Transfer
ecpri_proto.fields.pc_id2 = ProtoField.uint32("epri.pc_id", "PC_ID", base.HEX)
ecpri_proto.fields.seq_id2 = ProtoField.uint32("epri.seq_id", "SEQ_ID", base.HEX)
-- Message Type 4: Remote Memory Access
ecpri_proto.fields.rma_id = ProtoField.uint8("epri.rma_id", "Remote Memory Access ID", base.HEX)
ecpri_proto.fields.read_write = ProtoField.uint8("ecpri.read_write", "Read/Write", base.HEX, nil, 0xF0)
ecpri_proto.fields.req_resp = ProtoField.uint8("ecpri.req_resp", "Req/Resp", base.HEX, nil, 0x0F)
ecpri_proto.fields.element_id = ProtoField.uint16("epri.element_id", "Element ID", base.HEX)
ecpri_proto.fields.address = ProtoField.bytes("epri.address", "Address")
ecpri_proto.fields.length = ProtoField.uint16("ecpri.length", "Length", base.DEC)
-- Message Type 5: One-way Delay Measurement
ecpri_proto.fields.measurement_id = ProtoField.uint8("epri.measurement_id", "Measurement ID", base.HEX)
ecpri_proto.fields.action_type = ProtoField.uint8("epri.action_type", "Action Type", base.HEX)
ecpri_proto.fields.timestamp = ProtoField.bytes("epri.timestamp", "TimeStamp")
--BOB: uint48() not supported!! ecpri_proto.fields.timestamp_sec = ProtoField.uint48("ecpri.sec", "Seconds", base.DEC)
ecpri_proto.fields.timestamp_sec = ProtoField.bytes("ecpri.sec", "Seconds")
ecpri_proto.fields.timestamp_nanosec = ProtoField.uint32("ecpri.nanosec", "Seconds", base.DEC)
ecpri_proto.fields.compensation_value = ProtoField.uint64("epri.compensation_value", "Compensation Value", base.DEC)
-- Message Type 6: Remote Reset
ecpri_proto.fields.reset_id = ProtoField.uint16("ecpri.reset_id", "Reset ID", base.HEX)
ecpri_proto.fields.reset_code_op = ProtoField.uint8("epri.reset_code_op", "Reset Code Op", base.HEX)
-- Message Type 7: Event Indication
ecpri_proto.fields.event_id = ProtoField.uint8("ecpri.event_id", "Event ID", base.HEX)
ecpri_proto.fields.event_type = ProtoField.uint8("ecpri.event_type", "Event Type", base.HEX)
ecpri_proto.fields.seq_num = ProtoField.uint8("ecpri.seq_number", "Sequence Number", base.DEC)
ecpri_proto.fields.num_faults_notifs = ProtoField.uint8("ecpri.num_faults_notifs", "Number of Faults/Notifications", base.DEC)
ecpri_proto.fields.element = ProtoField.bytes("epri.element", "Element")
ecpri_proto.fields.element_id2 = ProtoField.uint16("epri.element_id", "Element ID", base.HEX)
ecpri_proto.fields.raise_cease = ProtoField.uint8("ecpri.raise_cease", "Raise/Cease", base.HEX, nil, 0xF0)
ecpri_proto.fields.fault_notif = ProtoField.uint16("ecpri.fault_notif", "Fault/Notif", base.HEX, nil, 0x0FFF)
ecpri_proto.fields.additional_info = ProtoField.uint32("epri.additional_info", "Additional Information", base.HEX)
-- Rest of Payload
ecpri_proto.fields.data = ProtoField.bytes("epri.data", "Data")

-- eCPRI Payload Size is the size in bytes of the payload part corresponding to the eCPRI message. It
-- does not include any padding bytes following the eCPRI message. The maximum supported payload
-- size is 216-1 but the actual size may be further limited by the maximum payload size of the underlying
-- transport network.
ecpri_proto.fields.padding = ProtoField.bytes("epri.padding", "Padding")

ecpri_proto_frame_length_too_small          = ProtoExpert.new("ecpri.frame_length_too_small.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_payload_size_too_big            = ProtoExpert.new("ecpri.payload_size_too_big.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_payload_size_too_small          = ProtoExpert.new("ecpri.payload_size_too_small.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_data_length_too_small           = ProtoExpert.new("ecpri.data_length_too_small.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_data_length_too_big             = ProtoExpert.new("ecpri.data_length_too_big.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_timestamp_not_defined           = ProtoExpert.new("ecpri.timestamp_not_defined.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_compensation_value_not_defined  = ProtoExpert.new("ecpri.compensation_value_not_defined.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_num_faults_notifs               = ProtoExpert.new("ecpri.num_faults_notifs.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
ecpri_proto_concatenation_bit               = ProtoExpert.new("ecpri.concatenation_bit.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
-- register them
ecpri_proto.experts = { ecpri_proto_frame_length_too_small, ecpri_proto_payload_size_too_big, ecpri_proto_payload_size_too_small, ecpri_proto_data_length_too_small, ecpri_proto_data_length_too_big,
                        ecpri_proto_timestamp_not_defined, ecpri_proto_compensation_value_not_defined, ecpri_proto_num_faults_notifs, concatenation_bit }

function ecpri_proto.dissector(buffer,pinfo,tree) 
    local reported_length = buffer:reported_len()  

    -- Check there's enough for eCPRI header
    if (reported_length < ECPRI_HEADER_LENGTH) then
        return 0
    end

    -- Update Protocol and Info columns
    pinfo.cols.protocol = "eCPRI" 
    pinfo.cols.info = "" -- This gets appended to below

    local offset = 0
    local concatenation = buffer(offset,1):bitfield(7,1)
    if (concatenation ~= 0) then
        pinfo.cols.info:append("Concatenation ");
    end
    
    repeat
       --- 4-byte boundary check for concatenation
       -- “C=1” indicates that another eCPRI message follows this one within the eCPRI PDU. In this case, 0
       -- to 3 padding byte(s) shall be added to ensure that the following eCPRI message starts at a 4-Byte
       -- boundary. Padding byte(s) shall be ignored when received.       
        if (offset % 4) ~= 0 then     
            offset = offset + 4 - (offset % 4) 
        end  

        -- Read Payload Size
        local payload_size = buffer(offset+2,2):uint()
        -- Read C-Bit (Concatenation)
        concatenation = buffer(offset,1):bitfield(7,1)
          
        -- eCPRI tree
        if (payload_size + ECPRI_HEADER_LENGTH <= reported_length) then
            ecpri_subtree = tree:add(ecpri_proto, buffer(), buffer(offset, payload_size + ECPRI_HEADER_LENGTH))            
        else
            ecpri_subtree = tree:add(ecpri_proto, buffer(), buffer(offset, -1))
            --BOB: https://www.wireshark.org/docs/wsdg_html_chunked/lua_module_Tree.html 
            --BOB: This function is provided for backwards compatibility only, and should not be used in new Lua code. 
            -- It may be removed in the future. You should only use TreeItem.add_proto_expert_info().
            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                  "eCPRI frame length "..reported_length.." is too small, should be minimum of " ..payload_size + ECPRI_HEADER_LENGTH)         
            ecpri_subtree:add_proto_expert_info(ecpri_proto_frame_length_too_small, "eCPRI frame length "..reported_length.." is too small, should be minimum of " ..payload_size + ECPRI_HEADER_LENGTH)                   
        end
       
        -- eCPRI header-subtree
        header_subtree = ecpri_subtree:add( ecpri_proto.fields.header, buffer(offset,ECPRI_HEADER_LENGTH) )
        header_subtree:add( ecpri_proto.fields.revision, buffer(offset,1))  
        header_subtree:add( ecpri_proto.fields.reserved, buffer(offset,1))      
        header_subtree:add( ecpri_proto.fields.cbit, buffer(offset,1))
        offset = offset + 1 
        
        -- add message_type to subtree, update message text and then append to info column
        local message_type = buffer(offset,1):uint()
        -- if I use message_type no "value" field appears in the pdml!!
        -- local messageItem = header_subtree:add( ecpri_proto.fields.message_type, message_type)  
        local messageItem = header_subtree:add( ecpri_proto.fields.message_type, buffer(offset,1))  
        messageItem:set_text("Message Type: "..getMessageTypeString(message_type, message_types).." ("..message_type..")")
        pinfo.cols.info:append(getMessageTypeString(message_type, message_types).." ("..message_type..") ")
        offset = offset + 1 

        header_subtree:add( ecpri_proto.fields.payload_size, buffer(offset,2))
        offset = offset + 2          
         
        -- eCPRI payload-subtree
        -- Length Check
        if (reported_length >= ECPRI_HEADER_LENGTH + payload_size) then
            payload_subtree = ecpri_subtree:add(ecpri_proto.fields.payload, buffer(offset, payload_size))             
        else
            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                "Payload Size "..payload_size.." is too big, should be maximum of "..reported_length - ECPRI_HEADER_LENGTH.. " is possible")
            ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_big, "Payload Size "..payload_size.." is too big, should be maximum of "..reported_length - ECPRI_HEADER_LENGTH)             
            payload_subtree = ecpri_subtree:add(ecpri_proto.fields.payload, buffer(offset, -1))                         
        end

        -- Just output the whole payload        
        -- ecpri_subtree:add(ecpri_proto.fields.payload, buffer(offset, payload_size))
        -- offset = offset + payload_size

        -- DECODE THE PAYLOAD
        local remaining_length = reported_length - offset
        if ( (message_type == 0x00) or (message_type == 0x01) ) then --IQ Data or Bit Sequence
            if (payload_size >= ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH) then
                    payload_subtree:add( ecpri_proto.fields.pc_id, buffer(offset,2))                    
                    offset = offset + 2
                    payload_subtree:add( ecpri_proto.fields.seq_id, buffer(offset,2))                     
                    offset = offset + 2
                    remaining_length = remaining_length - ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH                 
                    if (remaining_length >= payload_size - ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH) then
                        payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH))                        
                        offset = offset + payload_size - ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH
                    end
                end
            else
                --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                   "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH)
 		ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small,  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_0_1_PAYLOAD_MIN_LENGTH)                                      
            end         
        elseif message_type == 0x02 then -- Real-Time Control Data
            if (payload_size >= ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH) then              
                    payload_subtree:add( ecpri_proto.fields.rtc_id, buffer(offset,2))                    
                    offset = offset + 2
                    payload_subtree:add( ecpri_proto.fields.seq_id, buffer(offset,2))                     
                    offset = offset + 2
                    remaining_length = remaining_length - ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH                       
                    if (remaining_length >= payload_size - ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH) then
                        payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH))                        
                        offset = offset + payload_size - ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH
                    end
                end
            else
                --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                   "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH)
                ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small,  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_2_PAYLOAD_MIN_LENGTH)                                                      
            end                      
        elseif message_type == 0x03 then -- Generic Data Transfer
            if (payload_size >= ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH) then                
                    payload_subtree:add( ecpri_proto.fields.pc_id2, buffer(offset,4))                    
                    offset = offset + 4
                    payload_subtree:add( ecpri_proto.fields.seq_id2, buffer(offset,4))                     
                    offset = offset + 4
                    remaining_length = remaining_length - ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH                    
                    if remaining_length >= payload_size - ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH then
                        payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH))                        
                        offset = offset + payload_size - ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH
                    end
                end
            else
                --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                   "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH)               
                ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small,  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_3_PAYLOAD_MIN_LENGTH)                                                                      
            end
        elseif message_type == 0x04 then -- Remote Memory Access 
            if (payload_size >= ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH) then
                    payload_subtree:add( ecpri_proto.fields.rma_id, buffer(offset,1))  
                    offset = offset + 1
                    payload_subtree:add( ecpri_proto.fields.read_write, buffer(offset,1))  
                    payload_subtree:add( ecpri_proto.fields.req_resp, buffer(offset,1)) 
                    offset = offset + 1
                    payload_subtree:add( ecpri_proto.fields.element_id, buffer(offset,2)) 
                    offset = offset + 2
                    payload_subtree:add( ecpri_proto.fields.address, buffer(offset,6)) 
                    offset = offset + 6
                    local data_length = buffer(offset,2):uint()                     
                    payload_subtree:add( ecpri_proto.fields.length, buffer(offset,2)) --BOB: if i use data_length here pdml gives size="0"
                    offset = offset + 2
                    remaining_length = remaining_length - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH                    
                    if (remaining_length >= payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH) then
                        if ( data_length == (payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH) ) then
                            payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH))                            
                            offset = offset + payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH
                        elseif data_length < (payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH) then
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                 "Data Length  "..data_length.." is too small, should be "..payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)
                            ecpri_subtree:add_proto_expert_info(ecpri_proto_data_length_too_small, "Data Length  "..data_length.." is too small, should be "..payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)                                                                                  
                        else
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,               "Data Length  "..data_length.." is too big, should be "..payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)
                            ecpri_subtree:add_proto_expert_info(ecpri_proto_data_length_too_big, "Data Length  "..data_length.." is too big, should be "..payload_size - ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)                            
                        end
                    end
                end
            else
                --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)                              
                ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small, "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_4_PAYLOAD_MIN_LENGTH)              
            end             
        elseif message_type == 0x05 then
            if (payload_size >= ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH) then
                    payload_subtree:add( ecpri_proto.fields.measurement_id, buffer(offset,1))                     
                    offset = offset + 1
                    local action_type = buffer(offset,1):uint()                     
                    payload_subtree:add( ecpri_proto.fields.action_type, action_type)                   
                    offset = offset + 1
                    -- Time Stamp for seconds and nano-seconds
                    timestamp_subtree = payload_subtree:add(ecpri_proto.fields.timestamp, buffer(offset, 10))  
                    local timestamp_sec = buffer(offset,6):uint64()                         
                    timestamp_subtree:add( ecpri_proto.fields.timestamp_sec, buffer(offset,6))                        
                    offset = offset + 6
                    local timestamp_nanosec = buffer(offset,4):uint()                     
                    timestamp_subtree:add( ecpri_proto.fields.timestamp_nanosec, buffer(offset,4))  
                    offset = offset + 4
                    if (action_type >= ECPRI_MSG_TYPE_5_RESERVED_MIN) then
                        --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                 "Time stamp is not defined for Action Type "..action_type)                              
                        ecpri_subtree:add_proto_expert_info(ecpri_proto_timestamp_not_defined, "Time stamp is not defined for Action Type "..action_type)                                                                            
                    elseif ( (action_type ~= ECPRI_MSG_TYPE_5_REQ) and (action_type ~= ECPRI_MSG_TYPE_5_RESPONSE) and (action_type ~= ECPRI_MSG_TYPE_5_FOLLOWUP) and
                            (timestamp_sec ~= 0x0000000000000000) and (timestamp_nanosec ~= 0x00000000) ) then
                        --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                 "Time stamp is not defined for Action Type "..action_type..", should be 0")                         
			ecpri_subtree:add_proto_expert_info(ecpri_proto_timestamp_not_defined, "Time stamp is not defined for Action Type "..action_type..", should be 0")                         
                    end

                    local compensation_value = buffer(offset,8):uint64() 
                    payload_subtree:add( ecpri_proto.fields.compensation_value, buffer(offset,8))--:append_text(" = "):append_text(buffer(offset,8):float())
                    ---BOB: ??? proto_item_append_text(ti_comp_val, " = %fns", comp_val / 65536.0);
                    offset = offset + 8
                    if (action_type >= ECPRI_MSG_TYPE_5_RESERVED_MIN) then
                        --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                          "Compensation Value is not defined for Action Type "..action_type)                          
			ecpri_subtree:add_proto_expert_info(ecpri_proto_compensation_value_not_defined, "Compensation Value is not defined for Action Type "..action_type)                        
                    elseif ( (action_type ~= ECPRI_MSG_TYPE_5_REQ) and (action_type ~= ECPRI_MSG_TYPE_5_RESPONSE) and (action_type ~= ECPRI_MSG_TYPE_5_FOLLOWUP) and 
                              (compensation_value ~= 0x0000000000000000) ) then
                        --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                          "Compensation Value is not defined for Action Type "..action_type..", should be 0")                         
			ecpri_subtree:add_proto_expert_info(ecpri_proto_compensation_value_not_defined, "Compensation Value is not defined for Action Type "..action_type..", should be 0")                          
                    end

                    remaining_length = remaining_length - ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH
                    if (remaining_length >= payload_size - ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH) then
                        payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH))                            
                        offset = offset + payload_size - ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH
                    end
                end
                else
                    --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH)                              
                    ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small, "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_5_PAYLOAD_MIN_LENGTH)                                      
                end            
        elseif message_type == 0x06 then
            if (payload_size >= ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH) then
                    payload_subtree:add( ecpri_proto.fields.reset_id, buffer(offset,2))                    
                    offset = offset + 2
                    payload_subtree:add( ecpri_proto.fields.reset_code_op, buffer(offset,1)) 
                    offset = offset + 1
                    remaining_length = remaining_length - ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH                    
                    if (remaining_length >= payload_size - ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH) then
                        payload_subtree:add(ecpri_proto.fields.data, buffer(offset, payload_size - ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH))                        
                        offset = offset + payload_size - ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH
                    end
                end
            else
               --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH)
               ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small, "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_6_PAYLOAD_MIN_LENGTH)                               
            end              
        elseif message_type == 0x07 then
            if (payload_size >= ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH) then
                if (remaining_length >= ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH) then
                    payload_subtree:add( ecpri_proto.fields.event_id, buffer(offset,1))                     
                    offset = offset + 1
                    payload_subtree:add( ecpri_proto.fields.event_type, buffer(offset,1))
                    local event_type = buffer(offset,1):uint()                                         
                    offset = offset + 1   
                    payload_subtree:add( ecpri_proto.fields.seq_num, buffer(offset,1))                     
                    offset = offset + 1                                      
                    payload_subtree:add( ecpri_proto.fields.num_faults_notifs, buffer(offset,1))     
                    local num_faults_notifs = buffer(offset,1):uint()
                    offset = offset + 1  
                    -- Only for Event Type Fault Indication (0x00) and Notification Indication (0x02)
                    if ( (event_type == ECPRI_MSG_TYPE_7_FAULT_INDICATION) or (event_type == ECPRI_MSG_TYPE_7_NOTIF_INDICATION) ) then
                        --These two Event Types should have Number of Faults or Notifications > 0
                        if (num_faults_notifs > 0) then
                            -- Check Size of Elements
                            if ( payload_size == ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH + (num_faults_notifs * ECPRI_MSG_TYPE_7_ELEMENT_SIZE) ) then                            
                                -- Dissect elements in loop
                                for i = 0,num_faults_notifs-1,1 
                                do 
                                    element_subtree = payload_subtree:add(ecpri_proto.fields.element, buffer(offset, ECPRI_MSG_TYPE_7_ELEMENT_SIZE))                                    
                                    --BOB: ?? proto_item_prepend_text(element_item, "#%d: ", i + 1);
                                    element_subtree:add( ecpri_proto.fields.element_id2, buffer(offset,2)) 
                                    offset = offset + 2
                                    element_subtree:add( ecpri_proto.fields.raise_cease, buffer(offset,1)) 
                                    element_subtree:add( ecpri_proto.fields.fault_notif, buffer(offset,2))  
                                    local fault_notif = buffer(offset,2):uint() 
                                    offset = offset + 2
                                    element_subtree:add( ecpri_proto.fields.additional_info , buffer(offset,4))                                    
                                    offset = offset + 4
                                end
                            elseif ( payload_size < ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH + (num_faults_notifs * ECPRI_MSG_TYPE_7_ELEMENT_SIZE) ) then

                            else

                            end
                        else                         
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,             "Number of Faults/Notifications "..num_faults_notifs.." should be > 0" )
			    ecpri_subtree:add_proto_expert_info(ecpri_proto_num_faults_notifs, "Number of Faults/Notifications "..num_faults_notifs.." should be > 0")                            
                        end
                    elseif ( (event_type == ECPRI_MSG_TYPE_7_FAULT_INDICATION_ACK) or (event_type == ECPRI_MSG_TYPE_7_SYNC_REQUEST) or (event_type == ECPRI_MSG_TYPE_7_SYNC_ACK) or (event_type == ECPRI_MSG_TYPE_7_SYNC_END_INDICATION) ) then
                        -- Number of Faults/Notifs should be 0, only 4 Byte possible*/
                        if (payload_size > 4) then
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                "Payload Size "..payload_size.." should be 4" )                             
			    ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_big, "Payload Size "..payload_size.." should be 4")                            
                        end
                        -- These Event Types shouldn't have faults or notifications
                        if (num_faults_notifs ~= 0) then
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,             "Number of Faults/Notifications "..num_faults_notifs.." should be 0" )
			    ecpri_subtree:add_proto_expert_info(ecpri_proto_num_faults_notifs, "Number of Faults/Notifications "..num_faults_notifs.." should be 0" )                             
                        end
                    else
                        -- These Event Types are reserved, don't know how to decode 
                        if (num_faults_notifs ~= 0) then
                            --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,             "Number of Faults/Notifications "..num_faults_notifs..", but no knowledge about encoding, because Event Type is reserved." )                              
                            ecpri_subtree:add_proto_expert_info(ecpri_proto_num_faults_notifs, "Number of Faults/Notifications "..num_faults_notifs..", but no knowledge about encoding, because Event Type is reserved." )                                                     
                        end
                    end
                end
            else               
                --ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,                  "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH)                              
                ecpri_subtree:add_proto_expert_info(ecpri_proto_payload_size_too_small, "Payload Size "..payload_size.." is too small for encoding Message Type " ..message_type..", should be minimum of "..ECPRI_MSG_TYPE_7_PAYLOAD_MIN_LENGTH)                               
            end                 
        elseif message_type <=63 then
            message("Can't decode Reserved message _type "..message_type)                                                               
        else
            message("Can't decode Vendor Specific message _type "..message_type)                    
        end
    
    -- end    
until not(concatenation ~= 0 and reported_length - offset >= ECPRI_HEADER_LENGTH)   
if (concatenation ~= 0) then
--ecpri_subtree:add_expert_info(PI_PROTOCOL, PI_ERROR,             "Concatenation Bit is 1, should be 0")
ecpri_subtree:add_proto_expert_info(ecpri_proto_concatenation_bit, "Concatenation Bit is 1, should be 0") 
end

if offset ~=0 then
    original_dissector:call(buffer(offset):tvb(), pinfo, tree) 
end

end

original_dissector = Dissector.get("ethertype")
ether_table = DissectorTable.get("ethertype"):add(0xaefe,ecpri_proto)
