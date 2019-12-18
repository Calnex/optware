-- roe.lua
-- version 1.2
-- written by Bob Chalmers
-- 
-- Wireshark dissector routine for roe protocol

roe_proto = Proto("roe","Radio over Ethernet")

-- RoE lengths  
ROE_HEADER_LENGTH = 8

-- Field Encoding of subtypes
subtypes = {    {0,"RoE control"}, {1,"Reserved1"}, {2,"RoE structure-agnostic data"}, {3,"RoE structure-aware CPRI data"}, {4,"RoE Slow C&M CPRI"},
                -- 5-15 Reserved2
                {5,"Reserved2"}, {15,"Reserved2"},
                {16,"RoE native time domain data"}, {17,"RoE native frequency domain data"}, {18,"RoE native PRACH data"},  
                -- 19-127 Reserved3
                {19,"Reserved3"}, {127,"Reserved3"},  
                -- 128-191 Mapped
                {128,"Mapped"}, {191,"Mapped"}, 
                -- 192-251 Reserved4
                {192,"Reserved4"}, {251,"Reserved4"},                                                         
                 -- 252-255 Experimental
                {252,"Experimental"}, {255,"Experimental"}}

local function getSubtypeString(subtype, subtypeStrings)       
    for i,v in ipairs(subtypeStrings) do 
        if v[1] >= subtype then
            return v[2]
        end
    end
end

-- RoE Common Header
roe_proto.fields.header = ProtoField.uint64("roe.header", "RoE Common Header", base.HEX)
roe_proto.fields.sub_type = ProtoField.uint8("roe.sub_type", "Subtype", base.hex)
roe_proto.fields.flow_id = ProtoField.uint8("roe.flow_id", "Flow Identifier", base.HEX)
roe_proto.fields.length = ProtoField.uint16("roe.length", "Length", base.DEC)
roe_proto.fields.order_info = ProtoField.bytes("roe.order_info", "Ordering Information") --can be a sequence number or timestamp
-- RoE Payload
roe_proto.fields.payload = ProtoField.bytes("roe.payload", "Payload")
-- Message Types

-- Rest of Payload
roe_proto.fields.data = ProtoField.bytes("roe.data", "Data")

roe_proto_frame_length_too_small        = ProtoExpert.new("roe.frame_length_too_small.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
roe_proto_payload_length_too_big        = ProtoExpert.new("roe.payload_length_too_big.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
roe_proto_payload_length_too_small      = ProtoExpert.new("roe.payload_size_too_small.expert", "", expert.group.MALFORMED, expert.severity.ERROR)
-- register them
roe_proto.experts = { roe_proto_frame_length_too_small, roe_proto_payload_length_too_big, roe_proto_payload_length_too_small }


function roe_proto.dissector(buffer,pinfo,tree) 
    local reported_length = buffer:reported_len()  

    -- Check there's enough for RoE header
    if (reported_length < ROE_HEADER_LENGTH) then
        return 0
    end

    -- Update Protocol and Info columns
    pinfo.cols.protocol = "RoE" 
    pinfo.cols.info = "" -- This gets appended to below

    local offset = 0
  
    -- repeat
        -- Read payload length
        local payload_length = buffer(offset+2,2):uint()

        -- RoE tree
        if (payload_length + ROE_HEADER_LENGTH <= reported_length) then
            roe_subtree = tree:add(roe_proto, buffer(), buffer(offset, payload_length + ROE_HEADER_LENGTH))            
        else
            roe_subtree = tree:add(roe_proto, buffer(), buffer(offset, -1))      
            roe_subtree:add_proto_expert_info(roe_proto_frame_length_too_small, "RoE frame length "..reported_length.." is too small, should be minimum of " ..payload_length + ROE_HEADER_LENGTH)                   
        end
       
        -- RoE header-subtree
        header_subtree = roe_subtree:add( roe_proto.fields.header, buffer(offset,ROE_HEADER_LENGTH) )

        -- add sub_type to subtree, update message text and then append to info column
        local subtype = buffer(offset,1):uint() 
        local messageItem = header_subtree:add( roe_proto.fields.sub_type, buffer(offset,1))  
        messageItem:set_text("Subtype: "..getSubtypeString(subtype, subtypes).." ("..subtype..")")
        pinfo.cols.info:append(getSubtypeString(subtype, subtypes).." ("..subtype..") ")
        offset = offset + 1 
        
        header_subtree:add( roe_proto.fields.flow_id, buffer(offset,1))         
        offset = offset + 1

        header_subtree:add( roe_proto.fields.length, buffer(offset,2))
        offset = offset + 2 
        
        header_subtree:add( roe_proto.fields.order_info, buffer(offset,4))
        offset = offset + 4       
         
        -- RoE payload-subtree
        -- payload length Check
        if (reported_length >= ROE_HEADER_LENGTH + payload_length) then
            payload_subtree = roe_subtree:add(roe_proto.fields.payload, buffer(offset, payload_length))             
        else
            roe_subtree:add_proto_expert_info(roe_proto_payload_length_too_big, "Payload Length "..payload_size.." is too big, should be maximum of "..reported_length - ROE_HEADER_LENGTH)             
            payload_subtree = roe_subtree:add(roe_proto.fields.payload, buffer(offset, -1))                         
        end

        -- DECODE THE PAYLOAD
        offset = offset + payload_length
        
    -- until (reported_length - offset >= ROE_HEADER_LENGTH)   

    -- message ("offset "..offset)
    if offset ~=0 then
        original_dissector:call(buffer(offset):tvb(), pinfo, tree) 
    end

end

original_dissector = Dissector.get("ethertype")
ether_table = DissectorTable.get("ethertype"):add(0xfc3d,roe_proto)
